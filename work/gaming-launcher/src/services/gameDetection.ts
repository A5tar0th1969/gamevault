import type { Game } from '../types/game'

const platform = typeof process !== 'undefined' ? process.platform : 'linux'

export async function detectInstalledGames(): Promise<Game[]> {
  const detected: Game[] = []

  try {
    const steamPath = getSteamPath()
    const games = await scanSteamLibrary(steamPath)
    detected.push(...games)
  } catch {}

  try {
    const games = await scanEpicLibrary()
    detected.push(...games)
  } catch {}

  try {
    const games = await scanLinuxNative()
    detected.push(...games)
  } catch {}

  return detected
}

function getSteamPath(): string {
  if (platform === 'win32') {
    return 'C:\\Program Files (x86)\\Steam'
  } else if (platform === 'darwin') {
    return '~/Library/Application Support/Steam'
  }
  // Linux: check multiple possible Steam install paths
  const linuxPaths = [
    '~/.steam/steam',
    '~/.local/share/Steam',
    '/usr/share/steam',
    '~/.var/app/com.valvesoftware.Steam/data/Steam', // Flatpak
    '~/.steam/root',
  ]
  return linuxPaths[0] // Return first as default, scanner checks all
}

async function scanSteamLibrary(_path: string): Promise<Game[]> {
  // TODO: Parse Steam libraryfolders.vdf and app manifests
  return []
}

async function scanEpicLibrary(): Promise<Game[]> {
  const epicPaths: Record<string, string[]> = {
    win32: ['C:\\Program Files\\Epic Games', 'C:\\ProgramData\\Epic'],
    darwin: ['~/Library/Application Support/Epic'],
    linux: ['~/.local/share/Epic', '~/.config/Epic'],
  }
  // TODO: Parse Epic manifest files
  return []
}

async function scanLinuxNative(): Promise<Game[]> {
  if (platform !== 'linux') return []

  const nativePaths = [
    '~/.local/share/lutris/games',
    '~/.local/share/heroic/games',
    '~/.config/heroic/store',
    '/usr/share/games',
    '~/.local/share/games',
  ]
  // TODO: Scan for native Linux games, Lutris installs, Heroic launcher
  return []
}

export function getPlatformName(): string {
  if (platform === 'win32') return 'Windows'
  if (platform === 'darwin') return 'macOS'
  if (platform === 'linux') return 'Linux'
  return 'Unknown'
}

export function isPlatform(platformName: string): boolean {
  return platform === platformName
}
