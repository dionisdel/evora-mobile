/**
 * Layout del grupo autenticado.
 * Tab navigator con: Buscar, Cuestionario, Más.
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
        tabBarStyle: { backgroundColor: '#ffffff', borderTopColor: '#e2e8f0' },
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
          title: 'Cuestionario',
          href: null, // No mostrar en tab bar (se accede desde búsqueda)
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="checkbox-outline" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="mas"
        options={{
          title: 'Más',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="menu" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
