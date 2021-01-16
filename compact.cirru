
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:modules $ [] |respo.calcit/compact.cirru |lilac/compact.cirru |memof/compact.cirru |respo-ui.calcit/compact.cirru |respo-markdown.calcit/compact.cirru |reel.calcit/compact.cirru) (:version |0.0.1)
  :files $ {}
    |app.comp.container $ {}
      :ns $ quote
        ns app.comp.container $ :require ([] hsl.core :refer $ [] hsl) ([] respo-ui.core :as ui) ([] respo.core :refer $ [] defcomp defeffect <> >> div button textarea span input) ([] respo.comp.space :refer $ [] =<) ([] reel.comp.reel :refer $ [] comp-reel) ([] respo-md.comp.md :refer $ [] comp-md) ([] app.config :refer $ [] dev?)
      :defs $ {}
        |comp-container $ quote
          defcomp comp-container (reel)
            let
                store $ :store reel
                states $ :states store
                cursor $ either (:cursor states) ([])
                state $ either (:data states) ({} $ :content "\"")
              div
                {} $ :style (merge ui/global ui/row)
                textarea $ {} (:value $ :content state) (:placeholder "\"Content")
                  :style $ merge ui/expand ui/textarea ({} $ :height 320)
                  :on-input $ fn (e d!)
                    d! cursor $ assoc state :content (:value e)
                =< 8 nil
                div ({} $ :style ui/expand) (comp-md "|This is some content with `code`") (=< |8px nil)
                  button $ {} (:style ui/button) (:inner-text "\"Run")
                    :on-click $ fn (e d!) (println $ :content state)
                when dev? $ comp-reel (>> states :reel) reel ({})
      :proc $ quote ()
    |app.config $ {}
      :ns $ quote (ns app.config)
      :defs $ {}
        |cdn? $ quote
          def cdn? $ cond
              exists? js/window
              , false
            (exists? js/process)
              = "\"true" js/process.env.cdn
            :else false
        |dev? $ quote (def dev? true)
        |site $ quote
          def site $ {} (:dev-ui "\"http://localhost:8100/main-fonts.css") (:release-ui "\"http://cdn.tiye.me/favored-fonts/main-fonts.css") (:cdn-url "\"http://cdn.tiye.me/calcit-workflow/") (:title "\"Calcit") (:icon "\"http://cdn.tiye.me/logo/mvc-works.png") (:storage-key "\"workflow")
      :proc $ quote ()
    |app.main $ {}
      :ns $ quote
        ns app.main $ :require ([] respo.core :refer $ [] render! clear-cache! realize-ssr!) ([] app.comp.container :refer $ [] comp-container) ([] app.updater :refer $ [] updater) ([] app.schema :as schema) ([] reel.util :refer $ [] listen-devtools!) ([] reel.core :refer $ [] reel-updater refresh-reel) ([] reel.schema :as reel-schema) ([] app.config :as config)
      :defs $ {}
        |ssr? $ quote
          def ssr? $ some? (js/document.querySelector |meta.respo-ssr)
        |repeat! $ quote
          defn repeat! (duration cb)
            js/setTimeout
              fn () (echo "\"called") (cb)
                repeat! (* 1000 duration) cb
              * 1000 duration
        |dispatch! $ quote
          defn dispatch! (op op-data)
            when (and config/dev? $ not= op :states) (println "\"Dispatch:" op)
            reset! *reel $ reel-updater updater @*reel op op-data
        |main! $ quote
          defn main! () (println "\"Running mode:" $ if config/dev? "\"dev" "\"release") (if ssr? $ render-app! realize-ssr!) (render-app! render!)
            add-watch *reel :changes $ fn () (render-app! render!)
            listen-devtools! |a dispatch!
            .addEventListener js/window |beforeunload persist-storage!
            repeat! 60 persist-storage!
            let
                raw $ .getItem js/localStorage (:storage-key config/site)
              when (some? raw)
                dispatch! :hydrate-storage $ extract-cirru-edn (js/JSON.parse raw)
            println "|App started."
        |persist-storage! $ quote
          defn persist-storage! ()
            .setItem js/localStorage (:storage-key config/site)
              js/JSON.stringify $ to-cirru-edn (:store @*reel)
        |*reel $ quote
          defatom *reel $ -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
        |snippets $ quote
          defn snippets () (println config/cdn?)
        |render-app! $ quote
          defn render-app! (renderer)
            renderer mount-target (comp-container @*reel) (\ dispatch! % %2)
        |reload! $ quote
          defn reload! () (clear-cache!) (reset! *reel $ refresh-reel @*reel schema/store updater) (println "|Code updated.")
        |mount-target $ quote (def mount-target $ .querySelector js/document |.app)
      :proc $ quote ()
    |app.schema $ {}
      :ns $ quote (ns app.schema)
      :defs $ {}
        |store $ quote
          def store $ {}
            :states $ {} (:cursor $ [])
      :proc $ quote ()
    |app.updater $ {}
      :ns $ quote
        ns app.updater $ :require ([] respo.cursor :refer $ [] update-states)
      :defs $ {}
        |updater $ quote
          defn updater (store op data op-id op-time)
            case op (:states $ update-states store data) (:hydrate-storage data) (op store)
      :proc $ quote ()
