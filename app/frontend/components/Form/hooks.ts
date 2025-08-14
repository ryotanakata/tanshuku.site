import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import axios from 'axios';
import { urlSchema } from '@/schemas/urlSchema';
import { Url } from '@/types/urlType';
import { initializeAxios } from '@/utils/axios';

const useFormHooks = () => {
  const [url, setUrl] = useState<Url | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string>('');

  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors, isSubmitting },
    reset,
  } = useForm({
    resolver: zodResolver(urlSchema),
    mode: 'onChange'
  });

  useEffect(() => {
    const cleanup = initializeAxios();
    return cleanup;
  }, []);

  const onSubmit = async (data: z.infer<typeof urlSchema>) => {
    setLoading(true)
    setError('')

    try {
      const response = await axios.post('/api/urls', data)
      setUrl(response.data)
      reset()
    } catch (err: any) {
      if (err.response) {
        setError(err.response.data.error || '短縮URLの作成に失敗しました')
      } else if (err.request) {
        setError('サーバーからの応答がありません')
      } else {
        setError('ネットワークエラーが発生しました')
      }
    } finally {
      setLoading(false)
    }
  };

  const copyToClipboard = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text)
      alert('クリップボードにコピーしました！')
    } catch (err) {
      alert('コピーに失敗しました')
    }
  };

  return {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors, isSubmitting },
    reset,
    onSubmit,
    copyToClipboard,
    url,
    loading,
    error,
  };
}

export { useFormHooks };