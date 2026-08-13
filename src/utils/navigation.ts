/**
 * Utilidades de navegación a farmacias.
 * Abre Google Maps, Waze o fallback web.
 */
import { Linking, Platform } from 'react-native';

/**
 * Abrir navegación a una dirección.
 * Intenta abrir Google Maps/Waze nativos, con fallback a web.
 */
export async function navegarADireccion(direccion: string): Promise<void> {
  const encodedAddress = encodeURIComponent(direccion);

  if (Platform.OS === 'android') {
    // Intent de Android para navegación
    const url = `google.navigation:q=${encodedAddress}`;
    const canOpen = await Linking.canOpenURL(url);
    if (canOpen) {
      await Linking.openURL(url);
      return;
    }
  }

  if (Platform.OS === 'ios') {
    // URL scheme de Apple Maps
    const url = `maps://app?daddr=${encodedAddress}`;
    const canOpen = await Linking.canOpenURL(url);
    if (canOpen) {
      await Linking.openURL(url);
      return;
    }
  }

  // Fallback: Google Maps web
  const webUrl = `https://www.google.com/maps/dir/?api=1&destination=${encodedAddress}`;
  await Linking.openURL(webUrl);
}
