export const PLATFORM_STORES = {
  steam: {
    name: 'Steam',
    url: 'https://store.steampowered.com',
    color: '#1b2838',
    accent: '#66c0f4',
    icon: '🟦',
  },
  epic: {
    name: 'Epic Games',
    url: 'https://store.epicgames.com/en-US',
    color: '#2a2a2a',
    accent: '#ffffff',
    icon: '🟪',
  },
} as const

export function getStoreUrl(platform: string, appId?: string): string {
  switch (platform) {
    case 'steam':
      return appId ? `https://store.steampowered.com/app/${appId}` : PLATFORM_STORES.steam.url
    case 'epic':
      return appId
        ? `https://store.epicgames.com/en-US/p/${appId}`
        : PLATFORM_STORES.epic.url
    default:
      return ''
  }
}
