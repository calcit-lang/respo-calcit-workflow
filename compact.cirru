
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |respo.calcit/ |lilac/ |memof/ |respo-ui.calcit/ |respo-markdown.calcit/ |reel.calcit/
  :entries $ {}
  :files $ {}
    |app.comp.container $ {}
      :defs $ {}
        |comp-container $ %{} :CodeEntry
          :code $ quote
            defcomp comp-container (reel)
              let
                  store $ :store reel
                  states $ :states store
                  cursor $ or (:cursor states) ([])
                  state $ or (:data states)
                    {} $ :content "\""
                div
                  {} $ :style (merge ui/global ui/row)
                  textarea $ {}
                    :value $ :content state
                    :placeholder "\"Content"
                    :style $ merge ui/expand ui/textarea
                      {} $ :height 320
                    :on-input $ fn (e d!)
                      d! cursor $ assoc state :content (:value e)
                  =< 8 nil
                  div
                    {} $ :style ui/expand
                    comp-md "|This is some content with `code`"
                    =< |8px nil
                    button $ {} (:style ui/button) (:inner-text "\"Run")
                      :on-click $ fn (e d!)
                        println $ :content state
                  when dev? $ comp-reel (>> states :reel) reel ({})
          :doc |
      :ns $ %{} :CodeEntry
        :code $ quote
          ns app.comp.container $ :require (respo-ui.core :as ui)
            respo.core :refer $ defcomp defeffect <> >> div button textarea span input
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-reel
            respo-md.comp.md :refer $ comp-md
            app.config :refer $ dev?
        :doc |
    |app.config $ {}
      :defs $ {}
        |dev? $ %{} :CodeEntry
          :code $ quote
            def dev? $ = "\"dev" (get-env "\"mode" "\"release")
          :doc |
        |site $ %{} :CodeEntry
          :code $ quote
            def site $ {} (:storage-key "\"workflow")
          :doc |
      :ns $ %{} :CodeEntry
        :code $ quote (ns app.config)
        :doc |
    |app.main $ {}
      :defs $ {}
        |*reel $ %{} :CodeEntry
          :code $ quote
            defatom *reel $ -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
          :doc |
        |dispatch! $ %{} :CodeEntry
          :code $ quote
            defn dispatch! (op)
              when
                and config/dev? $ not= op :states
                js/console.log "\"Dispatch:" op
              reset! *reel $ reel-updater updater @*reel op
          :doc |
        |main! $ %{} :CodeEntry
          :code $ quote
            defn main! ()
              println "\"Running mode:" $ if config/dev? "\"dev" "\"release"
              if config/dev? $ load-console-formatter!
              render-app!
              add-watch *reel :changes $ fn (reel prev) (render-app!)
              listen-devtools! |k dispatch!
              js/window.addEventListener |beforeunload $ fn (event) (persist-storage!)
              flipped js/setInterval 60000 persist-storage!
              let
                  raw $ js/localStorage.getItem (:storage-key config/site)
                when (some? raw)
                  dispatch! $ :: :hydrate-storage (parse-cirru-edn raw)
              println "|App started."
          :doc |
        |mount-target $ %{} :CodeEntry
          :code $ quote
            def mount-target $ .!querySelector js/document |.app
          :doc |
        |persist-storage! $ %{} :CodeEntry
          :code $ quote
            defn persist-storage! () (js/console.log "\"persist")
              js/localStorage.setItem (:storage-key config/site)
                format-cirru-edn $ :store @*reel
          :doc |
        |reload! $ %{} :CodeEntry
          :code $ quote
            defn reload! () $ if (nil? build-errors)
              do (remove-watch *reel :changes) (clear-cache!)
                add-watch *reel :changes $ fn (reel prev) (render-app!)
                reset! *reel $ refresh-reel @*reel schema/store updater
                hud! "\"ok~" "\"Ok"
              hud! "\"error" build-errors
          :doc |
        |render-app! $ %{} :CodeEntry
          :code $ quote
            defn render-app! () $ render! mount-target (comp-container @*reel) dispatch!
          :doc |
      :ns $ %{} :CodeEntry
        :code $ quote
          ns app.main $ :require
            respo.core :refer $ render! clear-cache!
            app.comp.container :refer $ comp-container
            app.updater :refer $ updater
            app.schema :as schema
            reel.util :refer $ listen-devtools!
            reel.core :refer $ reel-updater refresh-reel
            reel.schema :as reel-schema
            app.config :as config
            "\"./calcit.build-errors" :default build-errors
            "\"bottom-tip" :default hud!
        :doc |
    |app.schema $ {}
      :defs $ {}
        |store $ %{} :CodeEntry
          :code $ quote
            def store $ {}
              :states $ {}
                :cursor $ []
          :doc |
      :ns $ %{} :CodeEntry
        :code $ quote (ns app.schema)
        :doc |
    |app.updater $ {}
      :defs $ {}
        |updater $ %{} :CodeEntry
          :code $ quote
            defn updater (store op op-id op-time)
              tag-match op
                  :states cursor s
                  update-states store cursor s
                (:hydrate-storage data) data
                _ $ do (println "\"unknown op:" op) store
          :doc |
      :ns $ %{} :CodeEntry
        :code $ quote
          ns app.updater $ :require
            respo.cursor :refer $ update-states
        :doc |
