import { useUIStore } from '../store/uiStore'
import './TopBar.css'

interface TopBarProps {
  onToggleFullscreen: () => void
}

const viewTitles: Record<string, string> = {
  library: 'Library',
  steam: 'Steam Store',
  epic: 'Epic Games Store',
  settings: 'Settings',
}

export default function TopBar({ onToggleFullscreen }: TopBarProps) {
  const { currentView, searchQuery, setSearchQuery } = useUIStore()

  return (
    <header className="topbar">
      <div className="topbar-section">
        <span className="view-title">{viewTitles[currentView] || 'Library'}</span>
      </div>
      <div className="topbar-center">
        <div className="search-container">
          <span className="search-icon">⌕</span>
          <input
            type="text"
            className="search-input"
            placeholder="Search games..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>
      <div className="topbar-right">
        <button className="topbar-btn fullscreen-btn" onClick={onToggleFullscreen} title="Fullscreen Mode">
          ⛶
        </button>
      </div>
    </header>
  )
}
