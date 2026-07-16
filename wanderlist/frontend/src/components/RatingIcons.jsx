// Simboli di voto disegnati a mano (non emoji): simmetrici rispetto a x=12
// così il taglio a metà (clip-path 50%) mostra davvero "mezzo" simbolo.

export function SandwichIcon({ size = 16, className }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" className={className} aria-hidden="true">
      {/* crosta superiore, arrotondata sopra */}
      <rect x="4" y="3" width="16" height="6" rx="5" fill="#E8C97A" />
      <rect x="4" y="6" width="16" height="3" fill="#E8C97A" />
      {/* farcitura */}
      <rect x="4" y="9" width="16" height="2.6" fill="#8FAF8F" />
      <rect x="4" y="11.6" width="16" height="2.6" fill="#C45C26" />
      {/* crosta inferiore, arrotondata sotto */}
      <rect x="4" y="14.2" width="16" height="6" rx="5" fill="#D4A853" />
      <rect x="4" y="14.2" width="16" height="3" fill="#D4A853" />
    </svg>
  )
}

export function MuseumIcon({ size = 16, className }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" className={className} aria-hidden="true">
      {/* timpano */}
      <path d="M12 3 L21 9.5 H3 Z" fill="#C45C26" />
      <rect x="3" y="9.5" width="18" height="1.6" fill="#9B3E14" />
      {/* colonne — gap centrale allineato a x=12 per un taglio pulito */}
      <rect x="5" y="12" width="2" height="6.5" fill="#E8C97A" />
      <rect x="9" y="12" width="2" height="6.5" fill="#E8C97A" />
      <rect x="13" y="12" width="2" height="6.5" fill="#E8C97A" />
      <rect x="17" y="12" width="2" height="6.5" fill="#E8C97A" />
      {/* base */}
      <rect x="3" y="18.5" width="18" height="2" fill="#9B3E14" />
    </svg>
  )
}
