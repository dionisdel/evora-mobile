/**
 * Layout del grupo autenticado.
 * Tab navigator: Buscar | Más
 * El cuestionario se navega como modal (sin tab).
 */
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

export default function AuthLayout() {
  return (
    <Tabs
      screenOptions={{
        headerStyle: { backgroundColor: '#1a2332' },
        headerTintColor: '#ffffff',
        tabBarActiveTintColor: '#3182ce',
        tabBarInactiveTintColor: '#a0aec0',
        tabBarStyle: { backgroundColor: '#ffffff', borderTopColor: '#e2e8f0', height: 56 },
        tabBarLabelStyle: { fontSize: 12 },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Buscar',
          headerTitle: 'Buscar farmacia',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="search" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="cuestionario/[id]"
        options={{
          href: null, // No mostrar en tab bar
          headerShown: false, // Usa su propio header
          tabBarStyle: { display: 'none' }, // Ocultar tabs en esta pantalla
        }}
      />
      <Tabs.Screen
        name="mas"
        options={{
          title: 'Más',
          headerTitle: 'Más opciones',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="menu" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
