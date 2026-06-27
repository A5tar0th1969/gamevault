import { useMemo, useState } from 'react'
import { useUIStore } from '../store/uiStore'
import { useGameStore } from '../store/gameStore'
import GameCard from './GameCard'
import './LibraryView.css'

type FilterType = 'all' | 'steam' | 'epic' | 'local'

export default function LibraryView() {
  const { searchQuery, selectGame, setShowGameDetails } = useUIStore()
  const { games } = useGameStore()
  const [activeFilter, setActiveFilter] = useState<FilterType>('all')

  const filteredGames = useMemo(() => {
    let result = games

    if (activeFilter !== 'all') {
      result = result.filter(g => g.platform === activeFilter)
    }

    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      result = result.filter(g =>
        g.name.toLowerCase().includes(q) ||
        g.developer?.toLowerCase().includes(q) ||
        g.genres?.some(gen => gen.toLowerCase().includes(q))
      )
    }

    return result
  }, [games, activeFilter, searchQuery])

  const handleGameClick = (gameId: string) => {
    const game = games.find(g => g.id === gameId)
    if (game) {
      selectGame(game)
      setShowGameDetails(true)
    }
  }

  const filters: { label: string; value: FilterType }[] = [
    { label: 'All', value: 'all' },
    { label: 'Steam', value: 'steam' },
    { label: 'Epic', value: 'epic' },
    { label: 'Local', value: 'local' },
  ]

  return (
    <div className="library-view">
      <div className="library-header">
        <h1 className="library-title">Game Library</h1>
        <div className="library-filters">
          {filters.map(f => (
            <button
              key={f.value}
              className={`filter-btn ${activeFilter === f.value ? 'active' : ''}`}
              onClick={() => setActiveFilter(f.value)}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>
      {filteredGames.length > 0 ? (
        <div className="game-grid">
          {filteredGames.map(game => (
            <GameCard
              key={game.id}
              game={game}
              onClick={() => handleGameClick(game.id)}
            />
          ))}
        </div>
      ) : (
        <div className="game-grid empty">
          <div className="empty-icon">🎮</div>
          <div className="empty-text">No games found</div>
          <div className="empty-sub">
            {searchQuery ? 'Try a different search term' : 'No games in this category yet'}
          </div>
        </div>
      )}
    </div>
  )
}
