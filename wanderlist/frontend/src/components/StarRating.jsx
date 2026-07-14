const ICONS = { food: '🥪', visit: '🏛️' }

function Icon({ glyph, half, empty }) {
  if (half) {
    return (
      <span className="relative inline-block leading-none" aria-hidden="true">
        <span className="opacity-20">{glyph}</span>
        <span className="absolute inset-0 overflow-hidden" style={{ clipPath: 'inset(0 50% 0 0)' }}>{glyph}</span>
      </span>
    )
  }
  return <span className={empty ? 'opacity-20' : ''} aria-hidden="true">{glyph}</span>
}

export function StarDisplay({ score, size = 'sm', type = 'food' }) {
  if (score == null) return <span className="text-ink/30 text-xs">—</span>

  const glyph = ICONS[type] ?? ICONS.food
  const rounded = Math.round(score * 2) / 2
  const full = Math.floor(rounded)
  const half = rounded - full === 0.5
  const empty = 5 - full - (half ? 1 : 0)
  const sz = size === 'lg' ? 'text-xl' : size === 'md' ? 'text-base' : 'text-sm'

  return (
    <span className={`inline-flex items-center gap-0.5 ${sz}`}>
      {Array.from({ length: full }).map((_, i) => <Icon key={`f${i}`} glyph={glyph} />)}
      {half && <Icon glyph={glyph} half />}
      {Array.from({ length: empty }).map((_, i) => <Icon key={`e${i}`} glyph={glyph} empty />)}
      <span className="star-score ml-1 text-sm">{score.toFixed(1)}</span>
    </span>
  )
}

const STEPS = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]

export function StarInput({ value, onChange, label, type = 'food' }) {
  const glyph = ICONS[type] ?? ICONS.food
  return (
    <div className="flex flex-col gap-1">
      {label && <span className="text-xs text-ink/60 font-medium">{label}</span>}
      <select
        value={value ?? ''}
        onChange={e => onChange(e.target.value === '' ? null : parseFloat(e.target.value))}
        className="input py-1.5 text-sm"
      >
        <option value="">—</option>
        {STEPS.map(s => (
          <option key={s} value={s}>{s} {glyph.repeat(Math.ceil(s) || 0)}</option>
        ))}
      </select>
    </div>
  )
}
