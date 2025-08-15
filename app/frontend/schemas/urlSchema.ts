import { z } from "zod";
import { REGEX_ZERO, REGEX_MIN_LENGTH, REGEX_MAX_LENGTH, REGEX_HOST, PROTOCOLS, VALIDATE_MESSAGES } from "@/constants/urlConstant";

const urlSchema = z.object({
  url: z
    .string()
    .min(REGEX_MIN_LENGTH, VALIDATE_MESSAGES.REQUIRED)
    .trim()
    .refine((url) => url.length > REGEX_ZERO, VALIDATE_MESSAGES.REQUIRED)
    .refine((url) => url.length <= REGEX_MAX_LENGTH, VALIDATE_MESSAGES.TOO_LONG)
    .refine((url) => {
      try {
        const parsed = new URL(url)
        return parsed.protocol === PROTOCOLS.HTTP || parsed.protocol === PROTOCOLS.HTTPS
      } catch {
        return false
      }
    }, VALIDATE_MESSAGES.INVALID_PROTOCOL)
    .refine((url) => {
      try {
        const parsed = new URL(url)
        return parsed.hostname && REGEX_HOST.test(parsed.hostname)
      } catch {
        return false
      }
    }, VALIDATE_MESSAGES.INVALID_DOMAIN)
    .refine((url) => {
      try {
        new URL(url)
        return true
      } catch {
        return false
      }
    }, VALIDATE_MESSAGES.INVALID)
})

export { urlSchema };