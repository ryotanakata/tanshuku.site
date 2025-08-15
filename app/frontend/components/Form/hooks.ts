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
  const [error, setError] = useState(false);
  const [copied, setCopied] = useState(false);
  const [generated, setGenerated] = useState(false);

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
    setError(false)

    try {
      const response = await axios.post('/api/urls', data)
      setUrl(response.data)
      setGenerated(true)
      await new Promise(resolve => setTimeout(resolve, 1500));
      setGenerated(false)
    } catch (error) {
      setError(true)
    } finally {
      setLoading(false)
    }
  };

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(url?.short_url || '')
      setCopied(true)
      await new Promise(resolve => setTimeout(resolve, 3000));
      setCopied(false)
    } catch (error) {
      setCopied(false)
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
    copied,
    generated
  };
}

export { useFormHooks };