import { useState } from 'react'

export default function App() {
  const [url, setUrl] = useState<string>('')
  const [shortUrl, setShortUrl] = useState<string>('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // TODO: 短縮URL生成のAPI呼び出し
    setShortUrl('https://tanshuku.site/abc123')
  }

  return (
    <div className="container">
      <h1>短縮URLサービス</h1>
      <form onSubmit={handleSubmit}>
        <input
          type="url"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          placeholder="短縮したいURLを入力してください"
          required
        />
        <button type="submit">短縮する</button>
      </form>
      {shortUrl && (
        <div className="result">
          <p>短縮URL: <a href={shortUrl}>{shortUrl}</a></p>
        </div>
      )}
    </div>
  )
}