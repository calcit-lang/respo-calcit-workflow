
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |js-ffi/
      :type-slots $ {} $ :dispatch-op |app.types/Op
  :files $ {}
    'app.comp.container $ %{} 'FileEntry
      :defs $ {} $ 'comp-container
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (reel)
            let
                store $ :store reel
                states $ :states store
                cursor $ decode-map-as
                  .unwrap-or (get states :cursor) ([])
                  :: 'List 'Dynamic
                state $ match (get states :data)
                  (:none) (app.types/StateData :content |)
                  (:some raw)
                    let
                        fields $ if (nil? raw) ({})
                          if (struct? raw) (&struct:to-map raw)
                            decode-map-as raw $ :: 'Map 'Tag 'Dynamic
                      decode-map-as
                        merge
                          {} $ :content |
                          , fields
                        , app.types/StateData
              div
                {} $ :class-name $ str-spaced css/preset css/global css/row
                textarea $ {}
                  :value $ :content state
                  :placeholder |Content
                  :class-name $ str-spaced css/expand css/textarea
                  :style $ {} $ :height 320
                  :on-input $ fn (e d!)
                    d! $ app.types/Op :states cursor $ assoc state :content
                      decode-map-as
                        .unwrap $ get e :value
                        , 'String
                =< 8 nil
                div
                  {} $ :class-name css/expand
                  <> "|This is some content with `code`"
                  =< |8px nil
                  button $ {} (:class-name css/button) (:inner-text |Run)
                    :on-click $ fn (e d!)
                      println $ :content state
                when dev? $ comp-typed-reel (>> states :reel) reel $ {}
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] $ :: 'reel.typed/State 'app.types/Op 'app.types/Store
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require (respo-ui.css :as css)
            respo.core :refer $ defcomp <> >> div button textarea
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-typed-reel
            app.config :refer $ dev?
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $
              get-env |mode
              , .unwrap-or |release
          :examples $ []
          :schema $ :: 'Bool
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site (app.types/SiteConfig :storage-key |workflow)
          :examples $ []
          :schema $ :: 'app.types/SiteConfig
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
          :require $ app.types :refer $ SiteConfig
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *reel (typed/new-reel schema/store)
          :examples $ []
          :schema $ :: 'Ref $ :: 'reel.typed/State 'app.types/Op 'app.types/Store
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when
              and config/dev? $ match op
                (:states cursor data) false
                _ true
              js/console.log |Dispatch: op
            reset! *reel $ next-reel op
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'Enum
            :features $ #{} :js-ffi
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            println "|Running mode:" $ if config/dev? |dev |release
            if config/dev? $ load-console-formatter!
            render-app!
            add-watch! *reel :changes $ fn (reel prev) (render-app!)
            listen-devtools! |k dispatch!
            match
              js-nullish->option $
                js-ffi.browser/window-local-storage
                , .get-item $ :storage-key config/site
              (:some raw)
                dispatch! $ :: :hydrate-storage $ parse-cirru-edn raw
              (:none) &unit
            js/window.addEventListener |beforeunload $ fn (event) (persist-storage!)
            js/window.addEventListener |visibilitychange $ fn (event)
              if
                = |hidden $ str js/document.visibilityState
                persist-storage!
            js/setInterval persist-storage! 60000
            println "|App started."
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn mount-target ()
            .unwrap $ respo.ffi.browser/query-selector |.app
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.dom/DomElement)
            :args $ []
            :features $ #{} :js-ffi
        'next-reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn next-reel (op)
            match (typed/decode-control op)
              (:some control) (typed/apply-control updater @*reel control)
              (:none)
                typed/record-op updater @*reel (app.types/decode-op op) (generate-id!) (shared/now-ms)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Enum
            :return $ :: 'reel.typed/State 'app.types/Op 'app.types/Store
        'persist-storage! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-storage! ()
            js/localStorage.setItem (:storage-key config/site)
              format-cirru-edn $ :store @*reel
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            if (nil? build-errors)
              do (remove-watch! *reel :changes) (clear-cache!)
                add-watch! *reel :changes $ fn (reel prev) (render-app!)
                reset! *reel $ typed/refresh updater @*reel schema/store
                hud! |ok~ |Ok
              hud! |error build-errors
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render! (mount-target) (comp-container @*reel)
              fn (op)
                if (enum? op) (dispatch! op) (raise "|render dispatch expected an Enum operation")
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
            respo.core :refer $ render! clear-cache!
            app.comp.container :refer $ comp-container
            app.updater :refer $ updater
            app.schema :as schema
            reel.util :refer $ listen-devtools!
            reel.typed :as typed
            js-ffi.shared :as shared
            app.config :as config
            |./calcit.build-errors :default build-errors
            |bottom-tip :default hud!
    'app.schema $ %{} 'FileEntry
      :defs $ {} $ 'store
        %{} 'CodeEntry (:doc |)
          :code $ quote $ def store
            app.types/Store :states $ {}
              :cursor $ []
              :data $ {}
          :examples $ []
          :schema $ :: 'app.types/Store
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
          :require $ app.types :refer $ Store
    'app.types $ %{} 'FileEntry
      :defs $ {}
        'Op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum Op
            :states (:: 'List 'Dynamic) 'Dynamic
            :hydrate-storage 'app.types/Store
          :examples $ []
          :schema $ :: 'EnumDef
        'SiteConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct SiteConfig (:storage-key 'String)
          :examples $ []
          :schema $ :: 'StructDef
        'StateData $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct StateData (:content 'String)
          :examples $ []
          :schema $ :: 'StructDef
        'Store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Store
            :states $ :: 'Map 'Tag 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'decode-op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-op (op)
            match op
              (:states cursor data)
                Op :states
                  decode-map-as cursor $ :: 'List 'Dynamic
                  , data
              (:hydrate-storage data)
                let
                    value $ if (enum? data)
                      match data
                        (:some legacy-store) legacy-store
                        _ $ raise "|Unsupported legacy storage wrapper"
                      , data
                  Op :hydrate-storage $ decode-map-as
                    if (struct? value) (&struct:to-map value) value
                    , Store
              _ $ raise "|Unknown workflow operation"
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.types/Op)
            :args $ [] 'Enum
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.types
    'app.updater $ %{} 'FileEntry
      :defs $ {} $ 'updater
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-id op-time)
            match op
              (:states cursor data)
                assoc store :states $ decode-map-as
                  respo.cursor/update-state-tree (:states store) cursor data
                  :: 'Map 'Tag 'Dynamic
              (:hydrate-storage data) data
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.types/Store)
            :args $ [] 'app.types/Store 'app.types/Op 'String 'Number
          :tests $ [] $ %{} 'TestEntry (:name |store-state-and-restore)
            :code $ quote $ let
                initial app.schema/store
                changed $ updater initial
                  app.types/Op :states ([] :draft) (app.types/StateData :content |hello)
                  , |probe 1
              assert= |hello $ :content $ decode-map-as
                &struct:to-map $ .unwrap-or
                  get-in (:states changed) ([] :draft :data)
                  , nil
                , app.types/StateData
              assert= initial $ updater initial
                app.types/decode-op $ :: :hydrate-storage $ parse-cirru-edn (format-cirru-edn initial)
                , |probe 2
              assert= initial $ updater initial
                app.types/decode-op $ :: :hydrate-storage $ &struct:to-map initial
                , |probe 3
              assert= initial $ updater initial
                app.types/decode-op $ :: :hydrate-storage $ parse-cirru-edn
                  format-cirru-edn $ Option :some initial
                , |probe 4
            :tags $ #{} :unit
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require $ respo.cursor :refer $ update-states
