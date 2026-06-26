const { app, BrowserWindow, ipcMain, screen } = require('electron')
const path = require('path')

let mainWindow = null
let isFullscreenMode = false
const platform = process.platform

const isLinux = platform === 'linux'
const isMac = platform === 'darwin'
const isWindows = platform === 'win32'

const createWindow = () => {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize

  const windowOptions = {
    width: Math.floor(width * 0.9),
    height: Math.floor(height * 0.9),
    minWidth: 1024,
    minHeight: 700,
    frame: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      webviewTag: true,
    },
    backgroundColor: '#0a0a0a',
    show: false,
  }

  // macOS: hidden title bar with traffic lights
  if (isMac) {
    windowOptions.titleBarStyle = 'hiddenInset'
  }

  // Linux: set app icon from any available path
  if (isLinux) {
    const iconPaths = [
      path.join(__dirname, '../public/icon.png'),
      path.join(__dirname, '../build/icon.png'),
      '/usr/share/pixmaps/gamevault.png',
    ]
    for (const p of iconPaths) {
      try {
        require('fs').accessSync(p)
        windowOptions.icon = p
        break
      } catch {}
    }
    // Wayland / X11 compatibility
    if (process.env.XDG_SESSION_TYPE === 'wayland') {
      app.commandLine.appendSwitch('enable-features', 'UseOzonePlatform')
      app.commandLine.appendSwitch('ozone-platform', 'wayland')
    }
  }

  if (!isLinux && !isMac) {
    windowOptions.icon = path.join(__dirname, '../public/icon.png')
  }

  mainWindow = new BrowserWindow(windowOptions)

  if (process.env.VITE_DEV_SERVER_URL) {
    mainWindow.loadURL(process.env.VITE_DEV_SERVER_URL)
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'))
  }

  mainWindow.once('ready-to-show', () => {
    mainWindow.show()
    // Linux: focus window after show for better WM integration
    if (isLinux) {
      mainWindow.focus()
    }
  })

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

app.whenReady().then(() => {
  // Linux: set app name for desktop environment integration
  if (isLinux) {
    app.setName('GameVault')
  }

  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

// Linux: quit when all windows closed (except macOS which keeps running)
app.on('window-all-closed', () => {
  if (!isMac) {
    app.quit()
  }
})

ipcMain.handle('toggle-fullscreen', () => {
  if (!mainWindow) return false
  isFullscreenMode = !isFullscreenMode

  if (isFullscreenMode) {
    mainWindow.setFullScreen(true)
    mainWindow.setMenuBarVisibility(false)
  } else {
    mainWindow.setFullScreen(false)
    mainWindow.setMenuBarVisibility(true)
  }

  return isFullscreenMode
})

ipcMain.handle('enter-fullscreen', () => {
  if (!mainWindow) return
  isFullscreenMode = true
  mainWindow.setFullScreen(true)
  mainWindow.setMenuBarVisibility(false)
})

ipcMain.handle('exit-fullscreen', () => {
  if (!mainWindow) return
  isFullscreenMode = false
  mainWindow.setFullScreen(false)
  mainWindow.setMenuBarVisibility(true)
})

ipcMain.handle('is-fullscreen', () => {
  return isFullscreenMode
})

ipcMain.handle('minimize-window', () => {
  if (mainWindow) mainWindow.minimize()
})

ipcMain.handle('close-window', () => {
  if (mainWindow) mainWindow.close()
})

ipcMain.handle('get-platform', () => {
  return process.platform
})
