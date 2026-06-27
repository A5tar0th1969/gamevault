import { useState } from 'react'
import './Settings.css'

interface SettingsProps {
  onToggleFullscreen: () => void
}

export default function Settings({ onToggleFullscreen }: SettingsProps) {
  const [startInFullscreen, setStartInFullscreen] = useState(false)
  const [minimizeToTray, setMinimizeToTray] = useState(false)
  const [showInstalledOnly, setShowInstalledOnly] = useState(false)
  const [theme, setTheme] = useState('dark')

  return (
    <div className="settings-view">
      <h1 className="settings-title">Settings</h1>

      <div className="settings-section">
        <div className="settings-section-title">Display</div>
        <div className="settings-card">
          <div className="settings-item">
            <div className="settings-item-info">
              <span className="settings-item-label">Fullscreen Game Mode</span>
              <span className="settings-item-desc">Launch into fullscreen SteamOS-like mode on startup</span>
            </div>
            <button
              className={`settings-toggle ${startInFullscreen ? 'active' : ''}`}
              onClick={() => setStartInFullscreen(!startInFullscreen)}
            >
              <span className="settings-toggle-knob" />
            </button>
          </div>
          <div className="settings-item">
            <div className="settings-item-info">
              <span className="settings-item-label">Theme</span>
              <span className="settings-item-desc">Choose your preferred visual theme</span>
            </div>
            <select
              className="settings-select"
              value={theme}
              onChange={(e) => setTheme(e.target.value)}
            >
              <option value="dark">Dark (Aniki)</option>
              <option value="darker">Darker</option>
              <option value="light">Light</option>
            </select>
          </div>
        </div>
      </div>

      <div className="settings-section">
        <div className="settings-section-title">Library</div>
        <div className="settings-card">
          <div className="settings-item">
            <div className="settings-item-info">
              <span className="settings-item-label">Show Installed Only</span>
              <span className="settings-item-desc">Only display games that are currently installed</span>
            </div>
            <button
              className={`settings-toggle ${showInstalledOnly ? 'active' : ''}`}
              onClick={() => setShowInstalledOnly(!showInstalledOnly)}
            >
              <span className="settings-toggle-knob" />
            </button>
          </div>
          <div className="settings-item">
            <div className="settings-item-info">
              <span className="settings-item-label">Minimize to System Tray</span>
              <span className="settings-item-desc">Keep GameVault running in the background</span>
            </div>
            <button
              className={`settings-toggle ${minimizeToTray ? 'active' : ''}`}
              onClick={() => setMinimizeToTray(!minimizeToTray)}
            >
              <span className="settings-toggle-knob" />
            </button>
          </div>
        </div>
      </div>

      <div className="settings-section">
        <div className="settings-section-title">Game Mode</div>
        <button className="settings-fullscreen-btn" onClick={onToggleFullscreen}>
          ⛶ Launch Fullscreen Game Mode
        </button>
        <p style={{ fontSize: 12, color: 'var(--text-tertiary)', marginTop: 8, textAlign: 'center' }}>
          Press <span className="settings-key">F11</span> or the fullscreen button to toggle
        </p>
      </div>

      <div className="settings-section">
        <div className="settings-section-title">About</div>
        <div className="settings-about">
          <div className="settings-about-title">GameVault</div>
          <div className="settings-about-version">Version 1.0.0</div>
          <div className="settings-about-desc">
            A gaming UI launcher inspired by Playnite and Steam.
            Integrates Steam Store and Epic Game Store.
            Fullscreen mode powered by Aniki ReMake UI design.
          </div>
        </div>
      </div>
    </div>
  )
}
