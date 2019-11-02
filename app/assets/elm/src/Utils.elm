module Utils exposing (isProjectExpanded)

import Dict
import Types


isProjectExpanded : Types.Project -> Types.ExpandedProjects -> Bool
isProjectExpanded project expandedProjects =
    case Dict.get (String.fromInt project.id) expandedProjects of
        Just value ->
            value

        Nothing ->
            False
