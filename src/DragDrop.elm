{-
Based on original code from Daniel Bachler (danyx23)
-}

module DragDrop (Model, Action(Drop), init, update, view) where

import Html exposing (Html, Attribute, div, text)
-- import Html.Attributes exposing (..)
import Html.Events exposing (onWithOptions)

import Json.Decode as Json exposing (andThen)
import Effects exposing (Effects)

import Decoders exposing (..)

-- MODEL

type HoverState
    = Normal
    | Hovering

type alias Model =
    { hoverState : HoverState -- set to Hovering if the user is hovering with content over the drop zone
    , message : String
    , defaultStyle : Attribute
    , hoverStyle : Attribute
    -- , files : List NativeFile    -- Do we need to store this in the library??
    }

init : Attribute -> Attribute -> Model
init = Model Normal ""

-- UPDATE

type Action
    = DragEnter -- user enters the drop zone while dragging something
    | DragLeave -- user leaves drop zone
    | Drop (List NativeFile)

update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        DragEnter ->
            ( { model | hoverState = Hovering }
            , Effects.none
            )
        DragLeave ->
            ( { model | hoverState = Normal }
            , Effects.none
            )
        Drop vals ->
            ( { model
                | hoverState = Normal
                -- , message = toString vals
              }
            , Effects.none
            )

-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
    div
        [ dropZoneStyle model
        , onDragEnter address DragEnter
        , onDragLeave address DragLeave
        , onDragOver address DragEnter
        , onDrop address
        ] [ text model.message ]

-- View event handlers
onDragFunction : String -> Signal.Address a -> a -> Attribute
onDragFunction nativeEventName address payload =
    onWithOptions
        nativeEventName
        {stopPropagation = False, preventDefault = True}
        Json.value
        (\_ -> Signal.message address payload)

onDragEnter : Signal.Address a -> a -> Attribute
onDragEnter = onDragFunction "dragenter"

onDragOver : Signal.Address a -> a -> Attribute
onDragOver = onDragFunction "dragover"

onDragLeave : Signal.Address a -> a -> Attribute
onDragLeave = onDragFunction "dragleave"

onDrop : Signal.Address Action -> Html.Attribute
onDrop address =
    onWithOptions
        "drop"
        {stopPropagation = True, preventDefault = True}
        -- (parseLength `andThen` parseFilenames)
        parseDroppedFiles
        (\vals -> Signal.message address (Drop vals))

-- View Styles
dropZoneStyle : Model -> Attribute
dropZoneStyle model =
    if model.hoverState == Normal
        then model.defaultStyle
        else model.hoverStyle