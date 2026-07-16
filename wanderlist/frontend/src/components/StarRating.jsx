import { SandwichIcon, MuseumIcon } from './RatingIcons'

const ICON_COMPONENTS = { food: SandwichIcon, visit: MuseumIcon }

function Icon({ IconComp, size, half, empty }) {
  if (half) {
    return (
      <span className="relative inline-block leading-none" aria-hidden="true" style={{ width: size, height: size }}>
        <span className="absolute inset-0 opacity-20"><IconComp size={size} /></span>
        <span className="absolute inset-0 overflow-hidden" style={{ clipPath: 'inset(0 50% 0 0)' }}>
          <IconComp size={size} />
        </span>
      </span>
    )
  }
  return (
    <span className={empty ? 'opacity-20' : ''} style={{ lineHeight: 0 }}>
      <IconComp size={size} />
    </span>
  )
}

export function StarDisplay({ score, size = 'sm', type = 'food' }) {
  if (score == null) return <span className="text-ink/30 text-xs">—</span>

  const IconComp = ICON_COMPONENTS[type] ?? SandwichIcon
  const px = size === 'lg' ? 22 : size === 'md' ? 18 : 15
  const rounded = Math.round(score * 2) / 2
  const full = Math.floor(rounded)
  const half = rounded - full === 0.5
  const empty = 5 - full - (half ? 1 : 0)
  const txtSz = size === 'lg' ? 'text-xl' : size === 'md' ? 'text-base' : 'text-sm'

  return (
    <span className={`inline-flex items-center gap-0.5 ${txtSz}`}>
      {Array.from({ length: full }).map((_, i) => <Icon key={`f${i}`} IconComp={IconComp} size={px} />)}
      {half && <Icon IconComp={IconComp} size={px} half />}
      {Array.from({ length: empty }).map((_, i) => <Icon key={`e${i}`} IconComp={IconComp} size={px} empty />)}
      <span className="star-score ml-1 text-sm">{score.toFixed(1)}</span>
    </span>
  )
}

export function StarInput({ value, onChange, label, type = 'food' }) {
  const IconComp = ICON_COMPONENTS[type] ?? SandwichIcon
  const positions = [1, 2, 3, 4, 5]

  function handlePick(e, position) {
    const rect = e.currentTarget.getBoundingClientRect()
    const clientX = e.changedTouches ? e.changedTouches[0].clientX : e.clientX
    const isLeftHalf = (clientX - rect.left) < rect.width / 2
    onChange(isLeftHalf ? position - 0.5 : position)
  }

  return (
    <div className="flex flex-col gap-1">
      {label && <span className="text-xs text-ink/60 font-medium">{label}</span>}
      <div className="flex items-center gap-1">
        {positions.map(pos => {
          const filled = value != null && value >= pos
          const half = value != null && value === pos - 0.5
          return (
            <button
              key={pos}
              type="button"
              onClick={e => handlePick(e, pos)}
              className="p-1 -m-0.5 touch-manipulation active:scale-90 transition-transform"
              aria-label={`Vota ${pos}`}
            >
              <Icon IconComp={IconComp} size={22} half={half} empty={!filled && !half} />
            </button>
          )
        })}
        {value != null && (
          <button type="button" onClick={() => onChange(null)}
            className="ml-1 text-ink/30 hover:text-ink/60 text-xs px-1" aria-label="Cancella voto">
            ✕
          </button>
        )}
        <span className="text-xs text-ink/40 ml-auto">{value != null ? value.toFixed(1) : '—'}</span>
      </div>
    </div>
  )
}
