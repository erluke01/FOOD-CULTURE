import { useId } from 'react'

// Logo: pin di viaggio con un ago di bussola stilizzato al centro.
export function Logo({ size = 32, className }) {
  const uid = useId()
  const gradId = `wl-pin-${uid}`

  return (
    <svg width={size} height={size} viewBox="0 0 100 100" className={className} aria-hidden="true">
      <defs>
        <linearGradient id={gradId} x1="20" y1="10" x2="80" y2="90" gradientUnits="userSpaceOnUse">
          <stop offset="0" stopColor="#E8825A" />
          <stop offset="1" stopColor="#C45C26" />
        </linearGradient>
      </defs>
      <path
        d="M50,8 C31,8 17,22 17,41 C17,63 50,93 50,93 C50,93 83,63 83,41 C83,22 69,8 50,8 Z"
        fill={`url(#${gradId})`}
      />
      <circle cx="50" cy="41" r="19" fill="#FAF7F2" />
      <polygon points="50,25 57,41 43,41" fill="#C45C26" />
      <polygon points="50,57 57,41 43,41" fill="#D4A853" />
    </svg>
  )
}
