import type { Game } from '../types/game'
import './GameCard.css'

interface GameCardProps {
  game: Game
  onClick: () => void
}

export default function GameCard({ game, onClick }: GameCardProps) {
  return (
    <div className="game-card" onClick={onClick}>
      <div className="game-card-cover">
        <img
          src={game.coverUrl}
          alt={game.name}
          loading="lazy"
          onError={(e) => {
            (e.target as HTMLImageElement).src = `data:image/svg+xml,${encodeURIComponent(
              `<svg xmlns="http://www.w3.org/2000/svg" width="300" height="400" viewBox="0 0 300 400">
                <rect fill="#1a1a1a" width="300" height="400"/>
                <text fill="#444" font-family="sans-serif" font-size="48" text-anchor="middle" x="150" y="200">🎮</text>
                <text fill="#555" font-family="sans-serif" font-size="14" text-anchor="middle" x="150" y="240">${game.name}</text>
              </svg>`
            )}`
          }}
        />
        <div className="game-card-overlay">
          <button
            className="game-card-play-btn"
            onClick={(e) => { e.stopPropagation(); onClick() }}
          >
            {game.isInstalled ? '▶ Play' : '▶ Install'}
          </button>
        </div>
      </div>
      <div className="game-card-info">
        <span className="game-card-name">{game.name}</span>
        <div className="game-card-meta">
          <span className={`game-card-platform ${game.platform}`}>
            {game.platform === 'steam' ? 'Steam' :
             game.platform === 'xbox' ? 'Xbox' :
             game.platform === 'epic' ? 'Epic' : 'Local'}
          </span>
          <span className={`game-card-installed ${game.isInstalled ? 'indicator' : ''}`}>
            {game.isInstalled ? '✓ Installed' : 'Not installed'}
          </span>
        </div>
      </div>
    </div>
  )
}
