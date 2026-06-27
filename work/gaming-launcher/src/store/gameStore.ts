import { create } from 'zustand'
import type { Game } from '../types/game'

interface GameState {
  games: Game[]
  loading: boolean
  setGames: (games: Game[]) => void
  addGame: (game: Game) => void
  removeGame: (id: string) => void
  setLoading: (loading: boolean) => void
}

const sampleGames: Game[] = [
  {
    id: 'steam-1',
    name: 'Counter-Strike 2',
    coverUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/730/header.jpg',
    platform: 'steam',
    storeUrl: 'https://store.steampowered.com/app/730',
    isInstalled: true,
    developer: 'Valve',
    publisher: 'Valve',
    releaseDate: '2023-09-27',
    genres: ['Action', 'FPS'],
    description: 'For over two decades, Counter-Strike has offered an elite competitive experience.',
  },
  {
    id: 'steam-2',
    name: 'Dota 2',
    coverUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/570/header.jpg',
    platform: 'steam',
    storeUrl: 'https://store.steampowered.com/app/570',
    isInstalled: true,
    developer: 'Valve',
    publisher: 'Valve',
    releaseDate: '2013-07-09',
    genres: ['Strategy', 'MOBA'],
    description: 'The most played game on Steam. Every day, millions of players enter the battle.',
  },
  {
    id: 'steam-3',
    name: 'ELDEN RING',
    coverUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1245620/header.jpg',
    platform: 'steam',
    storeUrl: 'https://store.steampowered.com/app/1245620',
    isInstalled: false,
    developer: 'FromSoftware',
    publisher: 'Bandai Namco',
    releaseDate: '2022-02-25',
    genres: ['RPG', 'Action'],
    description: 'The Golden Order has been broken. Rise, Tarnished, and be guided by grace.',
  },
  {
    id: 'steam-4',
    name: 'Baldur\'s Gate 3',
    coverUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1086940/header.jpg',
    platform: 'steam',
    storeUrl: 'https://store.steampowered.com/app/1086940',
    isInstalled: true,
    developer: 'Larian Studios',
    publisher: 'Larian Studios',
    releaseDate: '2023-08-03',
    genres: ['RPG', 'Adventure'],
  },
  {
    id: 'epic-1',
    name: 'Fortnite',
    coverUrl: 'https://cdn2.unrealengine.com/fortnite-og-1920x1080-631635025.jpg',
    platform: 'epic',
    storeUrl: 'https://store.epicgames.com/en-US/p/fortnite',
    isInstalled: true,
    developer: 'Epic Games',
    publisher: 'Epic Games',
    releaseDate: '2017-07-25',
    genres: ['Battle Royale', 'Action'],
  },
  {
    id: 'epic-2',
    name: 'Rocket League',
    coverUrl: 'https://cdn2.unrealengine.com/rocketleague-1920x1080-4e71f2b0b3c9.jpg',
    platform: 'epic',
    storeUrl: 'https://store.epicgames.com/en-US/p/rocket-league',
    isInstalled: true,
    developer: 'Psyonix',
    publisher: 'Epic Games',
    releaseDate: '2015-07-07',
    genres: ['Sports', 'Vehicular'],
  },
  {
    id: 'epic-3',
    name: 'Alan Wake 2',
    coverUrl: 'https://cdn2.unrealengine.com/alan-wake-2-1920x1080-853416836.jpg',
    platform: 'epic',
    storeUrl: 'https://store.epicgames.com/en-US/p/alan-wake-2',
    isInstalled: false,
    developer: 'Remedy Entertainment',
    publisher: 'Epic Games Publishing',
    releaseDate: '2023-10-27',
    genres: ['Horror', 'Action'],
  },
  {
    id: 'local-1',
    name: 'Cyberpunk 2077',
    coverUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg',
    platform: 'local',
    isInstalled: true,
    developer: 'CD Projekt Red',
    publisher: 'CD Projekt',
    releaseDate: '2020-12-10',
    genres: ['RPG', 'Open World'],
  },
  {
    id: 'local-2',
    name: 'The Witcher 3',
    coverUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/292030/header.jpg',
    platform: 'local',
    isInstalled: true,
    developer: 'CD Projekt Red',
    publisher: 'CD Projekt',
    releaseDate: '2015-05-19',
    genres: ['RPG', 'Action'],
  },
]

export const useGameStore = create<GameState>((set) => ({
  games: sampleGames,
  loading: false,
  setGames: (games) => set({ games }),
  addGame: (game) => set((state) => ({ games: [...state.games, game] })),
  removeGame: (id) => set((state) => ({ games: state.games.filter((g) => g.id !== id) })),
  setLoading: (loading) => set({ loading }),
}))
