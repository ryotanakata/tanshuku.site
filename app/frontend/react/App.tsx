import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import axios from 'axios'

// Zodスキーマの定義
const urlFormSchema = z.object({
  url: z
    .string()
    .min(1, 'URLを入力してください')
    .trim()
    .refine((url) => url.length > 0, 'URLを入力してください')
    .refine((url) => {
      try {
        new URL(url)
        return true
      } catch {
        return false
      }
    }, '有効なURLを入力してください')
    .refine((url) => {
      try {
        const parsed = new URL(url)
        return parsed.protocol === 'http:' || parsed.protocol === 'https:'
      } catch {
        return false
      }
    }, 'HTTPまたはHTTPSのURLを入力してください')
    .refine((url) => url.length <= 2048, 'URLが長すぎます（2048文字以内で入力してください）')
    .refine((url) => {
      try {
        const parsed = new URL(url)
        return parsed.hostname && parsed.hostname.length > 0
      } catch {
        return false
      }
    }, '有効なドメインを含むURLを入力してください')
})

type UrlFormData = z.infer<typeof urlFormSchema>

type ShortenedUrl = {
  original_url: string
  short_code: string
  short_url: string
  created_at: string
}

export default function App() {
  const [shortenedUrl, setShortenedUrl] = useState<ShortenedUrl | null>(null)
  const [loading, setLoading] = useState<boolean>(false)
  const [error, setError] = useState<string>('')

  // React Hook Formの設定
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
    setValue
  } = useForm<UrlFormData>({
    resolver: zodResolver(urlFormSchema),
    mode: 'onChange'
  })

  // axiosの設定とインターセプター
  useEffect(() => {
    // CSRFトークンを取得してaxiosのデフォルトヘッダーに設定
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
    if (token) {
      axios.defaults.headers.common['X-CSRF-Token'] = token
    }

    // デフォルトのヘッダー設定
    axios.defaults.headers.common['Content-Type'] = 'application/json'
    axios.defaults.headers.common['Accept'] = 'application/json'

    // リクエストインターセプター
    const requestInterceptor = axios.interceptors.request.use(
      (config) => {
        // リクエスト送信前のログ
        console.log('Sending request:', config.method?.toUpperCase(), config.url)
        return config
      },
      (error) => {
        return Promise.reject(error)
      }
    )

    // レスポンスインターセプター
    const responseInterceptor = axios.interceptors.response.use(
      (response) => {
        // 成功レスポンスのログ
        console.log('Response received:', response.status, response.config.url)
        return response
      },
      (error) => {
        // エラーレスポンスのログ
        if (error.response) {
          console.error('Response error:', error.response.status, error.response.data)
        } else if (error.request) {
          console.error('Request error:', error.message)
        } else {
          console.error('Error:', error.message)
        }
        return Promise.reject(error)
      }
    )

    // クリーンアップ関数
    return () => {
      axios.interceptors.request.eject(requestInterceptor)
      axios.interceptors.response.eject(responseInterceptor)
    }
  }, [])

  const onSubmit = async (data: UrlFormData) => {
    setLoading(true)
    setError('')

    try {
      const response = await axios.post('/api/urls', data)
      setShortenedUrl(response.data)
      reset() // フォームをリセット
    } catch (err: any) {
      if (err.response) {
        // サーバーからのエラーレスポンス
        setError(err.response.data.error || '短縮URLの作成に失敗しました')
      } else if (err.request) {
        // リクエストは送信されたがレスポンスがない
        setError('サーバーからの応答がありません')
      } else {
        // リクエストの設定時にエラーが発生
        setError('ネットワークエラーが発生しました')
      }
    } finally {
      setLoading(false)
    }
  }

  const copyToClipboard = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text)
      alert('クリップボードにコピーしました！')
    } catch (err) {
      alert('コピーに失敗しました')
    }
  }

  return (
    <div className="container">
      <h1>短縮URLサービス</h1>

      <form onSubmit={handleSubmit(onSubmit)} className="url-form">
        <div className="form-group">
          <input
            type="url"
            {...register('url')}
            placeholder="短縮したいURLを入力してください"
            className={errors.url ? 'error' : ''}
            disabled={loading}
          />
          {errors.url && (
            <span className="error-message">{errors.url.message}</span>
          )}
        </div>

        <button
          type="submit"
          disabled={loading || isSubmitting}
          className="submit-btn"
        >
          {loading ? '処理中...' : '短縮する'}
        </button>
      </form>

      {error && (
        <div className="error">
          <p>{error}</p>
        </div>
      )}

      {shortenedUrl && (
        <div className="result">
          <h3>短縮完了！</h3>
          <div className="url-info">
            <p><strong>元のURL:</strong> {shortenedUrl.original_url}</p>
            <p><strong>短縮URL:</strong>
              <a href={shortenedUrl.short_url} target="_blank" rel="noopener noreferrer">
                {shortenedUrl.short_url}
              </a>
              <button
                onClick={() => copyToClipboard(shortenedUrl.short_url)}
                className="copy-btn"
              >
                コピー
              </button>
            </p>
            <p><strong>作成日時:</strong> {new Date(shortenedUrl.created_at).toLocaleString('ja-JP')}</p>
          </div>
        </div>
      )}
    </div>
  )
}