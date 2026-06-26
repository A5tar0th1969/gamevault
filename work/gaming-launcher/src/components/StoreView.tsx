import { useMemo } from 'react'
import { useUIStore } from '../store/uiStore'
import { useGameStore } from '../store/gameStore'
import { PLATFORM_STORES } from '../services/storeIntegration'
import type { ViewSection, Game } from '../types/game'
import GameCard from './GameCard'
import './StoreView.css'

interface StoreViewProps {
  platform: 'steam' | 'xbox' | 'epic'
}

const storeUrls: Record<string, string> = {
  steam: 'https://store.steampowered.com',
  xbox: 'https://www.xbox.com/en-US/games',
  epic: 'https://store.epicgames.com/en-US',
}

export default function StoreView({ platform }: StoreViewProps) {
  const { setView, setShowGameDetails, selectGame } = useUIStore()
  const { games } = useGameStore()

  const storeInfo = PLATFORM_STORES[platform]
  const storeGames = games.filter(g => g.platform === platform)

  const handleGameClick = (gameId: string) => {
    const game = games.find(g => g.id === gameId)
    if (game) {
      selectGame(game)
      setShowGameDetails(true)
    }
  }

  return (
    <div className="store-view">
      <div className="store-header">
        <div className={`store-icon ${platform}`}>
          {platform === 'steam' ? '🟦' : platform === 'xbox' ? '🟩' : '🟪'}
        </div>
        <h1 className="store-title">{storeInfo.name}</h1>
      </div>
      <p className="store-description">
        Browse and launch your {storeInfo.name} games. Click a game to view details or open in the store.
      </p>
      <div className="store-actions">
        <button className="store-btn primary" onClick={() => window.open(storeUrls[platform], '_blank')}>
          Open {storeInfo.name} ↗
        </button>
        <button className="store-btn secondary" onClick={() => setView('library')}>
          View Library
        </button>
      </div>
      {storeGames.length > 0 ? (
        <>
          <h2 style={{ fontSize: 16, fontWeight: 600, marginBottom: 12, color: 'var(--text-secondary)' }}>
            Your {storeInfo.name} Games ({storeGames.length})
          </h2>
          <div className="game-grid">
            {storeGames.map(game => (
              <GameCard
                key={game.id}
                game={game}
                onClick={() => handleGameClick(game.id)}
              />
            ))}
          </div>
        </>
      ) : (
        <div className="store-placeholder">
          <div className="store-placeholder-icon">
            {platform === 'steam' ? '🟦' : platform === 'xbox' ? '🟩' : '🟪'}
          </div>
          <div className="store-placeholder-text">No {storeInfo.name} games in your library</div>
          <div className="store-placeholder-sub">
            Games from {storeInfo.name} will appear here once they are detected in your library.
            <br />
            Click "Open {storeInfo.name}" to browse the store.
          </div>
        </div>
      )}
    </div>
  )
}
