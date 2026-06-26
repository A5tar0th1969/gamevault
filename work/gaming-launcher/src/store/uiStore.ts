import { create } from 'zustand'
import type { Game, ViewSection } from '../types/game'

interface UIState {
  currentView: ViewSection
  isFullscreen: boolean
  searchQuery: string
  selectedGame: Game | null
  showGameDetails: boolean
  setView: (view: ViewSection) => void
  toggleFullscreen: () => void
  setFullscreen: (value: boolean) => void
  setSearchQuery: (query: string) => void
  selectGame: (game: Game | null) => void
  setShowGameDetails: (show: boolean) => void
}

export const useUIStore = create<UIState>((set) => ({
  currentView: 'library',
  isFullscreen: false,
  searchQuery: '',
  selectedGame: null,
  showGameDetails: false,
  setView: (view) => set({ currentView: view }),
  toggleFullscreen: () => set((state) => ({ isFullscreen: !state.isFullscreen })),
  setFullscreen: (value) => set({ isFullscreen: value }),
  setSearchQuery: (query) => set({ searchQuery: query }),
  selectGame: (game) => set({ selectedGame: game }),
  setShowGameDetails: (show) => set({ showGameDetails: show }),
}))
