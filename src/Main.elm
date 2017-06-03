module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Http exposing (get, Error, send)
import Json.Decode exposing (Decoder, field, list, map3, string)


-- TYPES


type alias Beer =
    { name : String
    , description : String
    , imageUrl : String
    }


type Message
    = FindBeer
    | ReceiveBeer (Result Error (List Beer))


type Broadcast
    = NotAsked
    | Loading
    | HttpFailure Error
    | HttpSuccess (List Beer)


type alias Model =
    { result : Broadcast
    }



-- DECODER


beer : Decoder Beer
beer =
    map3 Beer
        (field "name" string)
        (field "description" string)
        (field "image_url" string)



-- An example of 'commanding' the runtime to execute a side-effect; in this case
-- an HTTP GET. Note that we our application never executes the side-effect.
-- We simply register our intention to do so.


getRandomBeer : Cmd Message
getRandomBeer =
    send ReceiveBeer (get "https://api.punkapi.com/v2/beers/random" (list beer))



-- THE ELM ARCHITECTURE


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : ( Model, Cmd Message )
init =
    ( Model NotAsked, Cmd.none )


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        FindBeer ->
            ( { model | result = Loading }, getRandomBeer )

        ReceiveBeer (Ok b) ->
            ( { model | result = HttpSuccess b }, Cmd.none )

        ReceiveBeer (Err err) ->
            ( { model | result = HttpFailure err }, Cmd.none )


view : Model -> Html Message
view model =
    div []
        [ button [ onClick FindBeer ] [ text "Find me some beer!" ]
        , div []
            -- http://blog.jenkster.com/2016/06/how-elm-slays-a-ui-antipattern.html
            [ case model.result of
                NotAsked ->
                    p [] [ text "I'm waiting for your choice" ]

                Loading ->
                    p [] [ text "Loading a random beer" ]

                HttpFailure e ->
                    p [] [ text (toString e) ]

                HttpSuccess beer ->
                    p [] [ text (toString beer) ]
            ]
        ]
