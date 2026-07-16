/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      fontFamily: {
        display: ['"Playfair Display"', 'Georgia', 'serif'],
        sans: ['"Inter"', 'system-ui', 'sans-serif'],
      },
      colors: {
        ink:    { DEFAULT: '#1C1917', light: '#44403C' },
        paper:  { DEFAULT: '#FAF7F2', dark: '#F0EBE3' },
        terra:  { DEFAULT: '#C45C26', light: '#E8825A', dark: '#9B3E14' },
        sage:   { DEFAULT: '#5C7A5C', light: '#8FAF8F', dark: '#3D5C3D' },
        sky:    { DEFAULT: '#4A7FA5', light: '#7AACC8' },
        gold:   { DEFAULT: '#D4A853', light: '#E8C97A' },
      },
      borderRadius: { xl: '1rem', '2xl': '1.5rem' },
      transitionTimingFunction: {
        spring: 'cubic-bezier(0.34, 1.56, 0.64, 1)',
      },
    }
  },
  plugins: []
}
