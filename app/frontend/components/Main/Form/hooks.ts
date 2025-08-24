import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useState } from "react";
import { useHaptic } from "react-haptic";
import { useForm } from "react-hook-form";
import { Url } from "@/types/urlType";
import { fetchShotendUrl } from "@/utils/internalApi";
import { urlSchema } from "@/schemas/urlSchema";

const useFormHooks = () => {
  const [url, setUrl] = useState<Url | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(false);
  const [copied, setCopied] = useState(false);
  const [generated, setGenerated] = useState(false);
  const { vibrate } = useHaptic();

  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors, isSubmitting, isValid },
  } = useForm({
    resolver: zodResolver(urlSchema),
    mode: "onChange",
  });

  const onSubmit = async (data: z.infer<typeof urlSchema>) => {
    setLoading(true);
    setError(false);

    try {
      const response = await fetchShotendUrl(data.url);
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

  const handleClickShortenButton = () => {
    vibrate();
  };

  const handleClickCopyButton = async () => {
    vibrate();

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
    vibrate();
    setValue("url", "");
    setUrl(null);
  };

  return {
    url,
    loading,
    error,
    copied,
    generated,
    formState: { errors, isSubmitting, isValid },
    register,
    watch,
    onSubmit,
    handleSubmit,
    handleClickShortenButton,
    handleClickCopyButton,
    handleClickClearButton,
  };
};

export { useFormHooks };
