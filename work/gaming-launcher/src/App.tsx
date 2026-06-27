import { useEffect, useCallback } from 'react'
import { useUIStore } from './store/uiStore'
import { useGameStore } from './store/gameStore'
import Sidebar from './components/Sidebar'
import TopBar from './components/TopBar'
import LibraryView from './components/LibraryView'
import StoreView from './components/StoreView'
import Settings from './components/Settings'
import FullscreenMode from './components/FullscreenMode'
import GameDetailsPanel from './components/GameDetailsPanel'
import './App.css'

declare global {
  interface Window {
    electronAPI?: {
      toggleFullscreen: () => Promise<boolean>
      enterFullscreen: () => Promise<void>
      exitFullscreen: () => Promise<void>
      isFullscreen: () => Promise<boolean>
      minimizeWindow: () => Promise<void>
      closeWindow: () => Promise<void>
      getPlatform: () => Promise<string>
    }
  }
}

function App() {
  const { currentView, isFullscreen, setFullscreen, selectedGame, showGameDetails } = useUIStore()
  const { games } = useGameStore()

  const handleToggleFullscreen = useCallback(async () => {
    if (window.electronAPI) {
      const fs = await window.electronAPI.toggleFullscreen()
      setFullscreen(fs)
    } else {
      const el = document.documentElement
      if (!document.fullscreenElement) {
        await el.requestFullscreen()
        setFullscreen(true)
      } else {
        await document.exitFullscreen()
        setFullscreen(false)
      }
    }
  }, [setFullscreen])

  useEffect(() => {
    const handleFullscreenChange = () => {
      setFullscreen(!!document.fullscreenElement)
    }
    document.addEventListener('fullscreenchange', handleFullscreenChange)
    return () => document.removeEventListener('fullscreenchange', handleFullscreenChange)
  }, [setFullscreen])

  const renderMainContent = () => {
    switch (currentView) {
      case 'library':
        return <LibraryView />
      case 'steam':
        return <StoreView platform="steam" />
      case 'epic':
        return <StoreView platform="epic" />
      case 'settings':
        return <Settings onToggleFullscreen={handleToggleFullscreen} />
      default:
        return <LibraryView />
    }
  }

  if (isFullscreen) {
    return (
      <FullscreenMode
        games={games}
        onExitFullscreen={handleToggleFullscreen}
      />
    )
  }

  return (
    <div className="app-container">
      <div className="drag-region" />
      <Sidebar />
      <div className="app-content">
        <TopBar onToggleFullscreen={handleToggleFullscreen} />
        <div className="app-main">
          {renderMainContent()}
        </div>
      </div>
      {showGameDetails && selectedGame && (
        <GameDetailsPanel game={selectedGame} />
      )}
    </div>
  )
}

export default App
