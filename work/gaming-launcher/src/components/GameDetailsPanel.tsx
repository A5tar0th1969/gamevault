import { useUIStore } from '../store/uiStore'
import type { Game } from '../types/game'
import './GameDetailsPanel.css'

interface GameDetailsPanelProps {
  game: Game
}

export default function GameDetailsPanel({ game }: GameDetailsPanelProps) {
  const { setShowGameDetails, selectGame } = useUIStore()

  const handleClose = () => {
    setShowGameDetails(false)
    selectGame(null)
  }

  const platformLabel = {
    steam: 'Steam',
    epic: 'Epic Games',
    local: 'Local',
  }[game.platform]

  const storeUrls: Record<string, string> = {
    steam: 'https://store.steampowered.com',
    epic: 'https://store.epicgames.com/en-US',
  }

  return (
    <div className="game-details-overlay" onClick={handleClose}>
      <div className="game-details-panel" onClick={e => e.stopPropagation()}>
        <div className="game-details-banner">
          <img
            src={game.coverUrl}
            alt={game.name}
            onError={(e) => {
              (e.target as HTMLImageElement).style.display = 'none'
            }}
          />
          <div className="game-details-banner-gradient" />
          <button className="game-details-close" onClick={handleClose}>✕</button>
        </div>
        <div className="game-details-body">
          <h1 className="game-details-title">{game.name}</h1>
          <div className="game-details-developer">
            {game.developer && `by ${game.developer}`}
            {game.publisher && ` · ${game.publisher}`}
          </div>

          {game.genres && game.genres.length > 0 && (
            <div className="game-details-tags">
              {game.genres.map(genre => (
                <span key={genre} className="game-details-tag">{genre}</span>
              ))}
            </div>
          )}

          {game.description && (
            <p className="game-details-description">{game.description}</p>
          )}

          <div className="game-details-meta">
            <div className="game-details-meta-item">
              <span className="game-details-meta-label">Platform</span>
              <span className="game-details-meta-value">{platformLabel}</span>
            </div>
            {game.releaseDate && (
              <div className="game-details-meta-item">
                <span className="game-details-meta-label">Released</span>
                <span className="game-details-meta-value">{game.releaseDate}</span>
              </div>
            )}
            <div className="game-details-meta-item">
              <span className="game-details-meta-label">Status</span>
              <span className="game-details-meta-value">
                {game.isInstalled ? '✓ Installed' : 'Not installed'}
              </span>
            </div>
            {game.developer && (
              <div className="game-details-meta-item">
                <span className="game-details-meta-label">Developer</span>
                <span className="game-details-meta-value">{game.developer}</span>
              </div>
            )}
          </div>

          <div className="game-details-actions">
            <button className="store-btn primary">
              {game.isInstalled ? '▶ Play' : '⬇ Install'}
            </button>
            {game.platform !== 'local' && (
              <button
                className="store-btn secondary"
                onClick={() => window.open(
                  game.storeUrl || storeUrls[game.platform],
                  '_blank'
                )}
              >
                Open in {game.platform === 'steam' ? 'Steam' : 'Epic'} ↗
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
