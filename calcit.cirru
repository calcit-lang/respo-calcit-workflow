
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |js-ffi/
      :type-slots $ {} $ :dispatch-op 'app.types/Op
  :files $ {}
    'app.comp.container $ %{} 'FileEntry
      :defs $ {} $ 'comp-container
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (reel on-control)
            let
                store $ :store reel
                states $ :states store
                cursor $ decode-map-as
                  .unwrap-or (get states :cursor) ([])
                  List app.types/CursorKey
                state $ match (get states :data)
                  (:none) (app.types/StateData :content |)
                  (:some raw)
                    let
                        fields $ if (nil? raw) ({})
                          if (struct? raw) (&struct:to-map raw)
                            decode-map-as raw $ Map Tag Dynamic
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
                    hint-fn $ Fn respo.schema/RespoEvent
                      Fn *dispatch-op $ -> Unit
                      -> Unit
                    d! $ app.types/Op :edit-content cursor $ respo.core/event-value e
                space-x 8
                div
                  {} $ :class-name css/expand
                  <> "|This is some content with `code`"
                  space-x 8
                  button $ {} (:class-name css/button) (:inner-text |Run)
                    :on-click $ fn (e d!)
                      println $ :content state
                if dev?
                  Some $ comp-typed-reel (>> states :reel) reel ({}) on-control
                  , None
          :examples $ []
          :schema $ quote $ Fn (reel.typed/State app.types/Op app.types/Store)
            Fn reel.typed/Control $ -> Unit
            -> respo.schema/Component
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require (respo-ui.css :as css)
            respo.core :refer $ defcomp <> >> div button textarea
            respo.comp.space :refer $ space-x
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
          :schema $ quote Bool
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site (app.types/SiteConfig :storage-key |workflow)
          :examples $ []
          :schema $ quote SiteConfig
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
          :require $ app.types :refer $ SiteConfig
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *reel (typed/new-reel schema/store)
          :examples $ []
          :schema $ quote $ Ref (typed/State app.types/Op app.types/Store)
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when
              and config/dev? $ match op
                (:states cursor data) false
                _ true
              js/console.log |Dispatch: op
            reset! *reel $ typed/record-op updater @*reel op (generate-id!) (shared/now-ms)
            , &unit
          :examples $ []
          :schema $ quote $ Fn app.types/Op (-> Unit) (:features :js-ffi)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            println "|Running mode:" $ if config/dev? |dev |release
            if config/dev? $ load-console-formatter!
            try
              do
                match
                  js-nullish->option $
                    js-ffi.browser/window-local-storage
                    , .get-item $ :storage-key config/site
                  (:some raw)
                    dispatch! $ app.types/Op :hydrate-storage $ app.types/decode-store (parse-cirru-edn raw)
                  (:none) &unit
                render-app!
              fn (error)
                let
                    message $ :message $ shared/normalize-error error
                  hud! |error message
                  raise message
            add-watch! *reel :changes $ fn (reel prev) (render-app!)
            listen-devtools-toggle! |k $ fn () $ on-control! (typed/Control :toggle)
            js/window.addEventListener |beforeunload $ fn (event) (persist-storage!)
            js/window.addEventListener |visibilitychange $ fn (event)
              if
                = |hidden $ str js/document.visibilityState
                persist-storage!
            js/setInterval persist-storage! 60000
            println "|App started."
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn mount-target ()
            .unwrap $ respo.ffi.browser/query-selector |.app
          :examples $ []
          :schema $ quote $ Fn (-> respo.dom/DomElement) (:features :js-ffi)
        'on-control! $ %{} 'CodeEntry
          :doc "|Apply a Reel devtools Control; the panel calls this instead of dispatching :reel/* events."
          :code $ quote $ defn on-control! (control)
            reset! *reel $ typed/apply-control updater @*reel control
            , &unit
          :examples $ []
          :schema $ quote $ Fn typed/Control (-> Unit)
        'persist-storage! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-storage! ()
            js/localStorage.setItem (:storage-key config/site)
              format-cirru-edn $ :store @*reel
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
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
          :schema $ quote $ Fn (-> Unit)
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render-with! (mount-target)
              fn () $ comp-container @*reel on-control!
              , dispatch!
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
            respo.core :refer $ render-with! clear-cache!
            app.comp.container :refer $ comp-container
            app.updater :refer $ updater
            app.schema :as schema
            reel.util :refer $ listen-devtools-toggle!
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
          :schema $ quote Store
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
          :require $ app.types :refer $ Store
    'app.types $ %{} 'FileEntry
      :defs $ {}
        'CursorKey $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defunion CursorKey Tag String Number
          :examples $ []
          :schema $ quote UnionDef
        'Op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum Op
            :states (List app.types/CursorKey) Dynamic
            :edit-content (List app.types/CursorKey) String
            :hydrate-storage app.types/Store
          :examples $ []
          :schema $ quote EnumDef
        'SiteConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct SiteConfig (:storage-key String)
          :examples $ []
          :schema $ quote StructDef
        'StateData $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct StateData (:content String)
          :examples $ []
          :schema $ quote StructDef
        'Store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Store
            :states $ Map app.types/CursorKey Dynamic
          :examples $ []
          :schema $ quote StructDef
        'decode-store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-store (data)
            let
                value $ if (enum? data)
                  match data
                    (:some legacy-store) legacy-store
                    _ $ raise "|Unsupported legacy storage wrapper"
                  , data
              decode-map-as
                if (struct? value) (&struct:to-map value) value
                , Store
          :examples $ []
          :schema $ quote $ Fn V (-> Store) (:generics V)
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
                  Map app.types/CursorKey Dynamic
              (:edit-content cursor content)
                assoc store :states $ decode-map-as
                  respo.cursor/update-state-tree (:states store) cursor $ app.types/StateData :content content
                  Map app.types/CursorKey Dynamic
              (:hydrate-storage data) data
          :examples $ []
          :schema $ quote $ Fn app.types/Store app.types/Op String Number (-> app.types/Store)
          :tests $ [] $ %{} 'TestEntry (:name |store-state-and-restore)
            :code $ quote $ let
                initial app.schema/store
                changed $ updater initial
                  app.types/Op :edit-content ([] :draft) |hello
                  , |probe 1
                string-root $ updater initial
                  app.types/Op :states ([] |draft) false
                  , |string-root 5
                number-root $ updater string-root
                  app.types/Op :states ([] 2) |number-data
                  , |number-root 6
              assert= |hello $ :content $ decode-map-as
                &struct:to-map $ .unwrap-or
                  get-in (:states changed) ([] :draft :data)
                  , nil
                , app.types/StateData
              assert= initial $ updater initial
                app.types/Op :hydrate-storage $ app.types/decode-store $ parse-cirru-edn (format-cirru-edn initial)
                , |probe 2
              assert= initial $ updater initial
                app.types/Op :hydrate-storage $ app.types/decode-store $ &struct:to-map initial
                , |probe 3
              assert= initial $ updater initial
                app.types/Op :hydrate-storage $ app.types/decode-store $ parse-cirru-edn
                  format-cirru-edn $ Some initial
                , |probe 4
              assert= false $ .unwrap-or
                get-in (:states number-root) ([] |draft :data)
                , |missing-root-data
              assert= |number-data $ .unwrap-or
                get-in (:states number-root) ([] 2 :data)
                , |missing-root-data
              assert= number-root $ updater initial
                app.types/Op :hydrate-storage $ app.types/decode-store $ parse-cirru-edn (format-cirru-edn number-root)
                , |roundtrip 7
            :tags $ #{} :unit
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require $ respo.cursor :refer $ update-states
