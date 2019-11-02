port module ExpandedProjectsCache exposing (..)

import Dict
import Json.Decode as D
import Json.Encode as E
import Types


port expandedProjectsCache : E.Value -> Cmd msg


addToCache : Types.ExpandedProjects -> Cmd msg
addToCache expandedProjects =
    expandedProjectsCache (E.dict identity E.bool expandedProjects)


decodeExpandedProjectsCache : String -> Types.ExpandedProjects
decodeExpandedProjectsCache value =
    case D.decodeString (D.keyValuePairs D.bool) value of
        Ok decoded ->
            Dict.fromList decoded

        Err error ->
            let
                a =
                    Debug.log "error" error
            in
            Dict.empty
