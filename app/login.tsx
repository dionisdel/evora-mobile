/**
 * Pantalla de Login.
 * Formulario de autenticación para instaladores (coach/colaborador).
 * 
 * Incluye:
 * - Campos usuario/contraseña
 * - Mensajes de error descriptivos
 * - Bloqueo tras 5 intentos fallidos (15 min cooldown)
 * - Indicador de carga
 * - Preserva datos del formulario si hay error de conexión
 */
import { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useAuth } from '../src/hooks/useAuth';
import { useAuthStore } from '../src/store/auth.store';

export default function LoginScreen() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [lockCountdown, setLockCountdown] = useState<string | null>(null);
  const { login, isLoading, error } = useAuth();
  const { lockedUntil, loginAttempts } = useAuthStore();

  // Countdown timer para bloqueo
  useEffect(() => {
    if (!lockedUntil) {
      setLockCountdown(null);
      return;
    }

    const interval = setInterval(() => {
      const remaining = lockedUntil - Date.now();
      if (remaining <= 0) {
        setLockCountdown(null);
        return;
      }
      const minutes = Math.ceil(remaining / 60000);
      setLockCountdown(`Cuenta bloqueada. Espera ${minutes} min.`);
    }, 1000);

    return () => clearInterval(interval);
  }, [lockedUntil]);

  const handleLogin = async () => {
    if (!username.trim() || !password.trim()) return;
    await login({ username: username.trim(), password });
  };

  const isDisabled = isLoading || !!lockCountdown;
  const attemptsLeft = 5 - loginAttempts;

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.header}>
        <Text style={styles.logo}>ë·vora</Text>
        <Text style={styles.subtitle}>Instaladores</Text>
      </View>

      <View style={styles.form}>
        <TextInput
          style={[styles.input, isDisabled && styles.inputDisabled]}
          placeholder="Usuario"
          placeholderTextColor="#999"
          value={username}
          onChangeText={setUsername}
          autoCapitalize="none"
          autoCorrect={false}
          editable={!isDisabled}
          returnKeyType="next"
          accessible
          accessibilityLabel="Campo de usuario"
        />

        <TextInput
          style={[styles.input, isDisabled && styles.inputDisabled]}
          placeholder="Contraseña"
          placeholderTextColor="#999"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          editable={!isDisabled}
          returnKeyType="go"
          onSubmitEditing={handleLogin}
          accessible
          accessibilityLabel="Campo de contraseña"
        />

        {/* Mensaje de error */}
        {error && <Text style={styles.error}>{error}</Text>}

        {/* Countdown de bloqueo */}
        {lockCountdown && <Text style={styles.lockMessage}>{lockCountdown}</Text>}

        {/* Intentos restantes (solo si ha fallado al menos una vez) */}
        {loginAttempts > 0 && !lockCountdown && (
          <Text style={styles.attemptsText}>
            {attemptsLeft} intento{attemptsLeft !== 1 ? 's' : ''} restante{attemptsLeft !== 1 ? 's' : ''}
          </Text>
        )}

        <TouchableOpacity
          style={[styles.button, isDisabled && styles.buttonDisabled]}
          onPress={handleLogin}
          disabled={isDisabled}
          activeOpacity={0.7}
          accessible
          accessibilityRole="button"
          accessibilityLabel="Iniciar sesión"
        >
          {isLoading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>Entrar</Text>
          )}
        </TouchableOpacity>
      </View>

      <Text style={styles.version}>v1.0.0</Text>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a2332',
    justifyContent: 'center',
    paddingHorizontal: 32,
  },
  header: {
    alignItems: 'center',
    marginBottom: 48,
  },
  logo: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  subtitle: {
    fontSize: 16,
    color: '#a0aec0',
    marginTop: 8,
  },
  form: {
    gap: 16,
  },
  input: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 16,
    color: '#333',
    minHeight: 48,
  },
  inputDisabled: {
    opacity: 0.6,
  },
  error: {
    color: '#fc8181',
    fontSize: 14,
    textAlign: 'center',
  },
  lockMessage: {
    color: '#fbd38d',
    fontSize: 14,
    textAlign: 'center',
    fontWeight: '500',
  },
  attemptsText: {
    color: '#a0aec0',
    fontSize: 12,
    textAlign: 'center',
  },
  button: {
    backgroundColor: '#3182ce',
    borderRadius: 8,
    paddingVertical: 16,
    alignItems: 'center',
    marginTop: 8,
    minHeight: 52,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  version: {
    color: '#4a5568',
    fontSize: 12,
    textAlign: 'center',
    marginTop: 32,
  },
});
