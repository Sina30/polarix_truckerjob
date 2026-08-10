import { createI18n } from "vue-i18n";

// SSOT: same locales/*.json files the Lua side reads via shared/locale.lua.
// Keys are semantic (e.g. "notify.vehicle_bought"), values are the display text per language.
import de from "../../locales/de.json";
import en from "../../locales/en.json";
import fr from "../../locales/fr.json";
import es from "../../locales/es.json";
import ptBr from "../../locales/pt-br.json";
import pl from "../../locales/pl.json";
import nl from "../../locales/nl.json";
import it from "../../locales/it.json";
import tr from "../../locales/tr.json";

export const i18n = createI18n({
  legacy: false,
  locale: "de",
  fallbackLocale: "en",
  messages: { de, en, fr, es, "pt-br": ptBr, pl, nl, it, tr },
});
