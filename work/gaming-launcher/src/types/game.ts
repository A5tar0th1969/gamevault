export interface Game {
  id: string
  name: string
  coverUrl: string
  platform: 'steam' | 'epic' | 'local'
  storeUrl?: string
  isInstalled: boolean
  lastPlayed?: Date
  playTime?: number
  description?: string
  developer?: string
  publisher?: string
  releaseDate?: string
  genres?: string[]
}

export type ViewSection = 'library' | 'steam' | 'epic' | 'settings'
