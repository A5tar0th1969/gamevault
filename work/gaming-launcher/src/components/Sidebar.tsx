import { useUIStore } from '../store/uiStore'
import { useGameStore } from '../store/gameStore'
import './Sidebar.css'

const navItems = [
  { id: 'library' as const, label: 'Library', icon: '🎮', section: 'main' },
  { id: 'steam' as const, label: 'Steam', icon: '🟦', section: 'stores' },
  { id: 'epic' as const, label: 'Epic Games', icon: '🟪', section: 'stores' },
  { id: 'settings' as const, label: 'Settings', icon: '⚙️', section: 'bottom' },
]

export default function Sidebar() {
  const { currentView, setView } = useUIStore()
  const { games } = useGameStore()

  const getBadgeCount = (platform: string) => {
    return games.filter(g => g.platform === platform).length
  }

  const getActiveClass = (id: string) => {
    if (id === 'steam' && currentView === 'steam') return 'steam-active'
    if (id === 'epic' && currentView === 'epic') return 'epic-active'
    return ''
  }

  const storeItems = navItems.filter(n => n.section === 'stores')
  const mainItems = navItems.filter(n => n.section === 'main')
  const bottomItems = navItems.filter(n => n.section === 'bottom')

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <div className="sidebar-logo">GV</div>
        <span className="sidebar-title">GameVault</span>
      </div>
      <nav className="sidebar-nav">
        {mainItems.map((item) => (
          <button
            key={item.id}
            className={`nav-item ${currentView === item.id ? 'active' : ''}`}
            onClick={() => setView(item.id)}
          >
            <span className="nav-icon">{item.icon}</span>
            <span>{item.label}</span>
          </button>
        ))}
        
        <div className="nav-section-label">Stores</div>
        {storeItems.map((item) => (
          <button
            key={item.id}
            className={`nav-item ${currentView === item.id ? 'active' : ''} ${getActiveClass(item.id)}`}
            onClick={() => setView(item.id)}
          >
            <span className="nav-icon">{item.icon}</span>
            <span>{item.label}</span>
            <span className="nav-item-badge">{getBadgeCount(item.id)}</span>
          </button>
        ))}
      </nav>
      <div className="sidebar-footer">
        {bottomItems.map((item) => (
          <button
            key={item.id}
            className={`nav-item ${currentView === item.id ? 'active' : ''}`}
            onClick={() => setView(item.id)}
          >
            <span className="nav-icon">{item.icon}</span>
            <span>{item.label}</span>
          </button>
        ))}
      </div>
    </aside>
  )
}
