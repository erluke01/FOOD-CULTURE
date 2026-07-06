export function StarDisplay({ score, size = 'sm' }) {
  if (score == null) return <span className="text-ink/30 text-xs">—</span>

  const full = Math.floor(score)
  const half = score - full >= 0.25 && score - full < 0.75
  const empty = 5 - full - (half ? 1 : 0)
  const sz = size === 'lg' ? 'text-xl' : size === 'md' ? 'text-base' : 'text-sm'

  return (
    <span className={`inline-flex items-center gap-0.5 ${sz}`}>
      {Array.from({ length: full }).map((_, i) => <span key={`f${i}`}>★</span>)}
      {half && <span>⯨</span>}
      {Array.from({ length: empty }).map((_, i) => <span key={`e${i}`} className="opacity-20">★</span>)}
      <span className="star-score ml-1 text-sm">{score.toFixed(1)}</span>
    </span>
  )
}

const STEPS = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]

export function StarInput({ value, onChange, label }) {
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
          <option key={s} value={s}>{s} {'★'.repeat(Math.ceil(s))}</option>
        ))}
      </select>
    </div>
  )
}
