import React, { useState } from 'react'

interface Props {
  title?: string
}

const App: React.FC<Props> = ({ title = "Rails + Vite + React + TypeScript" }) => {
  const [count, setCount] = useState<number>(0)

  const handleIncrement = (): void => {
    setCount(prev => prev + 1)
  }

  return (
    <div className="p-6 max-w-sm mx-auto bg-white rounded-xl shadow-lg">
      <h1 className="text-2xl font-bold text-gray-900 mb-4">
        {title}
      </h1>
      <div className="space-y-4">
        <p className="text-gray-600">Count: {count}</p>
        <button
          onClick={handleIncrement}
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
        >
          Increment
        </button>
      </div>
    </div>
  )
}

export default App