import { zodResolver } from "@hookform/resolvers/zod";
import axios from "axios";
import { z } from "zod";
import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import { Url } from "@/types/urlType";
import { initializeAxios } from "@/utils/axios";
import { urlSchema } from "@/schemas/urlSchema";

const useFormHooks = () => {
  const [url, setUrl] = useState<Url | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(false);
  const [copied, setCopied] = useState(false);
  const [generated, setGenerated] = useState(false);

  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors, isSubmitting },
  } = useForm({
    resolver: zodResolver(urlSchema),
    mode: "onChange",
  });

  useEffect(() => {
    const cleanup = initializeAxios();
    return cleanup;
  }, []);

  const onSubmit = async (data: z.infer<typeof urlSchema>) => {
    setLoading(true);
    setError(false);

    try {
      const response = await axios.post("/api/urls", data);
      setUrl(response.data);
      setGenerated(true);
      await new Promise((resolve) => setTimeout(resolve, 1500));
      setGenerated(false);
    } catch (error) {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  const handleClickCopyButton = async () => {
    try {
      await navigator.clipboard.writeText(url?.short_url || "");
      setCopied(true);
      await new Promise((resolve) => setTimeout(resolve, 3000));
      setCopied(false);
    } catch (error) {
      setCopied(false);
    }
  };

  const handleClickClearButton = () => {
    setValue("url", "");
    setUrl(null);
  };

  return {
    url,
    loading,
    error,
    copied,
    generated,
    formState: { errors, isSubmitting },
    register,
    watch,
    onSubmit,
    handleSubmit,
    handleClickCopyButton,
    handleClickClearButton,
  };
};

export { useFormHooks };
