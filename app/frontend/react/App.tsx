import { useState } from 'react'


export default function App ({ title = "Rails + Vite + React + TypeScript + SCSS Modules" }) {
  const [count, setCount] = useState<number>(0)

  const handleIncrement = (): void => {
    setCount(prev => prev + 1)
  }

  return (
    <div className="p-6 max-w-4xl mx-auto space-y-6">
      <h1 className="text-3xl font-bold text-center mb-8">
        {title}
      </h1>

      {/* Counter Section */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-xl font-semibold mb-4">Counter Example</h2>
        <div className="space-y-4">
          <p className="text-gray-600 text-lg">Count: {count}</p>
          <button
            onClick={handleIncrement}
            className="btn primary"
          >
            Increment
          </button>
        </div>
      </div>

      {/* Button Variants Showcase */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-xl font-semibold mb-4">Button Variants</h2>
        <div className="space-y-4">
          <div className="flex flex-wrap gap-4">
            <button className="btn primary">Primary</button>
            <button className="btn secondary">Secondary</button>
            <button className="btn success">Success</button>
            <button className="btn danger">Danger</button>
          </div>
          <div className="flex flex-wrap gap-4">
            <button className="btn primary small">Small</button>
            <button className="btn primary large">Large</button>
            <button className="btn primary" disabled>Disabled</button>
          </div>
        </div>
      </div>
    </div>
  )
}