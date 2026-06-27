import { useState, useEffect, useMemo, useRef } from 'react'
import { useUIStore } from '../store/uiStore'
import { useGameStore } from '../store/gameStore'
import type { Game } from '../types/game'
import './FullscreenMode.css'

interface FullscreenModeProps {
  games: Game[]
  onExitFullscreen: () => void
}

type FsSection = 'home' | 'library' | 'steam' | 'epic'

export default function FullscreenMode({ games, onExitFullscreen }: FullscreenModeProps) {
  const [activeSection, setActiveSection] = useState<FsSection>('home')
  const [activeGameId, setActiveGameId] = useState<string | null>(null)
  const [time, setTime] = useState(new Date())

  const featuredGame = useMemo(() => {
    const installed = games.filter(g => g.isInstalled)
    return installed.length > 0
      ? installed[Math.floor(Math.random() * installed.length)]
      : games[0]
  }, [games])

  const activeGame = useMemo(() => {
    if (activeGameId) return games.find(g => g.id === activeGameId)
    return featuredGame
  }, [games, activeGameId, featuredGame])

  const steamGames = games.filter(g => g.platform === 'steam')
  const epicGames = games.filter(g => g.platform === 'epic')
  const installedGames = games.filter(g => g.isInstalled)

  useEffect(() => {
    const timer = setInterval(() => setTime(new Date()), 1000)
    return () => clearInterval(timer)
  }, [])

  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape' || e.key === 'F11') {
        onExitFullscreen()
      }
    }
    window.addEventListener('keydown', handleKey)
    return () => window.removeEventListener('keydown', handleKey)
  }, [onExitFullscreen])

  const timeStr = time.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })

  const navItems: { id: FsSection; label: string; icon: string }[] = [
    { id: 'home', label: 'Home', icon: '⌂' },
    { id: 'library', label: 'Library', icon: '🎮' },
    { id: 'steam', label: 'Steam', icon: '🟦' },
    { id: 'epic', label: 'Epic', icon: '🟪' },
  ]

  const renderContent = () => {
    switch (activeSection) {
      case 'home':
        return renderHome()
      case 'library':
        return renderGameShelf('My Library', games)
      case 'steam':
        return renderGameShelf('Steam Games', steamGames, 'steam-active')
      case 'epic':
        return renderGameShelf('Epic Games', epicGames, 'epic-active')
    }
  }

  const renderHome = () => (
    <>
      <div className="fullscreen-section">
        <div className="fullscreen-section-header">
          <h2 className="fullscreen-section-title">Continue Playing</h2>
        </div>
        <div className="fullscreen-shelf">
          {installedGames.slice(0, 8).map(game => (
            <FullscreenTile
              key={game.id}
              game={game}
              isActive={activeGameId === game.id}
              onClick={() => setActiveGameId(game.id)}
            />
          ))}
        </div>
      </div>

      <div className="fullscreen-section">
        <div className="fullscreen-section-header">
          <h2 className="fullscreen-section-title">Stores</h2>
        </div>
        <div className="fullscreen-featured-stores">
          <div className="fullscreen-store-card steam" onClick={() => setActiveSection('steam')}>
            <div className="fullscreen-store-card-icon">🟦</div>
            <div className="fullscreen-store-card-name">Steam</div>
            <div className="fullscreen-store-card-count">{steamGames.length} games</div>
          </div>
          <div className="fullscreen-store-card epic" onClick={() => setActiveSection('epic')}>
            <div className="fullscreen-store-card-icon">🟪</div>
            <div className="fullscreen-store-card-name">Epic Games</div>
            <div className="fullscreen-store-card-count">{epicGames.length} games</div>
          </div>
        </div>
      </div>

      {installedGames.length > 0 && (
        <div className="fullscreen-section">
          <div className="fullscreen-section-header">
            <h2 className="fullscreen-section-title">Installed Games</h2>
            <button className="fullscreen-section-link" onClick={() => setActiveSection('library')}>
              View All →
            </button>
          </div>
          <div className="fullscreen-shelf">
            {installedGames.map(game => (
              <FullscreenTile
                key={game.id}
                game={game}
                isActive={activeGameId === game.id}
                onClick={() => setActiveGameId(game.id)}
              />
            ))}
          </div>
        </div>
      )}
    </>
  )

  const renderGameShelf = (title: string, shelfGames: Game[], activeClass = '') => (
    <div className="fullscreen-section">
      <div className="fullscreen-section-header">
        <h2 className="fullscreen-section-title">{title}</h2>
        <span className="fullscreen-section-link">{shelfGames.length} games</span>
      </div>
      {shelfGames.length > 0 ? (
        <div className="fullscreen-shelf">
          {shelfGames.map(game => (
            <FullscreenTile
              key={game.id}
              game={game}
              isActive={activeGameId === game.id}
              onClick={() => setActiveGameId(game.id)}
              activeClass={activeClass}
            />
          ))}
        </div>
      ) : (
        <div style={{ padding: 32, textAlign: 'center', color: 'var(--text-tertiary)' }}>
          No games found in this section.
        </div>
      )}
    </div>
  )

  return (
    <div className="fullscreen-mode">
      <div className="fullscreen-topbar">
        <div className="fullscreen-topbar-left">
          <div className="fullscreen-logo">GV</div>
          <nav className="fullscreen-nav">
            {navItems.map(item => (
              <button
                key={item.id}
                className={`fullscreen-nav-btn ${activeSection === item.id ? 'active' : ''}`}
                onClick={() => { setActiveSection(item.id); setActiveGameId(null) }}
              >
                {item.label}
              </button>
            ))}
          </nav>
        </div>
        <div className="fullscreen-topbar-right">
          <span className="fullscreen-clock">{timeStr}</span>
          <button className="fullscreen-exit-btn" onClick={onExitFullscreen}>
            Exit Fullscreen
          </button>
        </div>
      </div>

      {activeGame && (
        <div className="fullscreen-hero">
          <div
            className="fullscreen-hero-bg"
            style={{ backgroundImage: `url(${activeGame.coverUrl})` }}
          />
          <div className="fullscreen-hero-gradient" />
          <div className="fullscreen-hero-content">
            <div className="fullscreen-hero-cover">
              <img
                src={activeGame.coverUrl}
                alt={activeGame.name}
                onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }}
              />
            </div>
            <div className="fullscreen-hero-info">
              <h1 className="fullscreen-hero-title">{activeGame.name}</h1>
              <div className="fullscreen-hero-meta">
                <span className={`fullscreen-hero-platform ${activeGame.platform}`}>
                  {activeGame.platform === 'steam' ? 'Steam' :
                   activeGame.platform === 'epic' ? 'Epic Games' : 'Local'}
                </span>
                {activeGame.developer && (
                  <span style={{ color: 'rgba(255,255,255,0.4)', fontSize: 13 }}>
                    {activeGame.developer}
                  </span>
                )}
              </div>
              {activeGame.description && (
                <p className="fullscreen-hero-desc">{activeGame.description}</p>
              )}
              <div className="fullscreen-hero-actions">
                <button className="fullscreen-hero-btn play">
                  {activeGame.isInstalled ? '▶ Play' : '⬇ Install'}
                </button>
                <button className="fullscreen-hero-btn info">
                  More Info
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <div className="fullscreen-content">
        {renderContent()}
      </div>
    </div>
  )
}

function FullscreenTile({
  game,
  isActive,
  onClick,
  activeClass = '',
}: {
  game: Game
  isActive: boolean
  onClick: () => void
  activeClass?: string
}) {
  return (
    <div className={`fullscreen-game-tile ${isActive ? 'active' : ''}`} onClick={onClick}>
      <div className={`fullscreen-game-tile-cover ${activeClass}`}>
        <img
          src={game.coverUrl}
          alt={game.name}
          loading="lazy"
          onError={(e) => {
            (e.target as HTMLImageElement).src = `data:image/svg+xml,${encodeURIComponent(
              `<svg xmlns="http://www.w3.org/2000/svg" width="160" height="214" viewBox="0 0 160 214">
                <rect fill="#1a1a1a" width="160" height="214"/>
                <text fill="#444" font-family="sans-serif" font-size="24" text-anchor="middle" x="80" y="110">🎮</text>
              </svg>`
            )}`
          }}
        />
      </div>
      <div className="fullscreen-game-tile-name">{game.name}</div>
    </div>
  )
}
