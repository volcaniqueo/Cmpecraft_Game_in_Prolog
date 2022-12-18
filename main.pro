% volkan ozturk
% 2019400033
% compiling: yes
% complete: yes
:- ['cmpecraft.pro'].

:- init_from_map.
% 10 points
% Distance is the sum of the absolute values of the differences of the coordinates.
manhattan_distance(A, B, Distance) :-
    nth0(0, A, A0), nth0(1, A, A1), nth0(0, B, B0), nth0(1, B, B1),
    Distance is (abs(A0 - B0) + abs(A1 - B1)).
% 10 points
% Recursive predicate to find the minimum element of a list. It modifies list recursively such that if the current element is smaller or
% equal than the next element, next element gets the value of current element and predicate is called again with the tail part of the list.
minimum_of_list([X], X).
minimum_of_list([H|T], Minimum) :-
    [H1 | T1] = T,
    (H =< H1 -> (Tlist = [H | T1], minimum_of_list(Tlist, Minimum));
    minimum_of_list(T, Minimum)).
% 10 points
% First findall is used to find all the <ObjectType> elements of a given state. Then, findall is used to find the Manhattan Distance's of all elements with respect
% to agent's location. Then, all distances get sorted with the keysort and the nearest one is chosen with nth0() predicate.
find_nearest_type([AD, OD, _], ObjectType, ObjectKey, Object, Distance) :-
    findall(K-Obj, (get_dict(K, OD, Obj), get_dict(type, Obj, ObjectType)), ResultList),
    findall(Dist-ObjKey, (nth0(_, ResultList, ObjKey- ObjPair), get_dict(x, ObjPair, Val1),
    get_dict(y, ObjPair, Val2),get_dict(x, AD, Val3), get_dict(y, AD, Val4), 
    manhattan_distance([Val1, Val2], [Val3, Val4], Dist)), FinalList),
    keysort(FinalList, SortedFinalList), nth0(0, SortedFinalList, Distance-ObjectKey),
    get_dict(ObjectKey, OD, Object).
% 10 points
% Recursive predicate for creating a list; with <OrderType>, X times. Used for constituting Action Lists.
my_write(0, [], _) :- !.
my_write(X, [H|T], OrderType) :- 
    Y is X - 1, my_write(Y, T, OrderType), H = OrderType.
% Calculates the distance between X, Y coordinates of the location and creates the necessary Action List.
navigate_to([AD, _, _], X, Y, ActionList, DepthLimit) :-
    get_dict(x, AD, Val3), get_dict(y, AD, Val4),
    Xdist is X - Val3, Ydist is Y - Val4,
    (Xdist =< 0 -> Absx is abs(Xdist), my_write(Absx, X_List, go_left);
    my_write(Xdist, X_List, go_right)),
    (Ydist =< 0 -> Absy is abs(Ydist), my_write(Absy, Y_List, go_up);
    my_write(Ydist, Y_List, go_down)),
    append(X_List, Y_List, ActionList),
    length(ActionList, NumMoves), NumMoves =< DepthLimit.
% 10 points
% Predicate first calls the find_nearest_type predicate and gets the tree to be choppped. Then asks navigate_to predicate to create
% necessary Action List. If agent has stone_axe in its inventory, then 2 left_clicks are needed. Otherwise 4 left_clicks are needed. Necessary
% click actions are added with append to finalize Action List.
chop_nearest_tree([AD, OD, T], ActionList) :-
    find_nearest_type([AD, OD, T], tree, _, Object, Distance), 
    get_dict(x, Object, X), get_dict(y, Object, Y),
    navigate_to([AD, OD, T], X, Y, ActionListMove, Distance),
    (get_dict(inventory, AD, Inv), get_dict(stone_axe, Inv, _) ->
    my_write(2, ActionListClick, left_click_c);
    my_write(4, ActionListClick, left_click_c)),
    append(ActionListMove, ActionListClick, ActionList).
% 10 points
% Predicate first calls the find_nearest_type predicate and gets the stone to be mined. Then asks navigate_to predicate to create
% necessary Action List. If agent has stone_pickaxe in its inventory, then 2 left_clicks are needed. Otherwise 4 left_clicks are needed. Necessary
% click actions are added with append to finalize Action List.
mine_nearest_stone([AD, OD, T], ActionList) :-
    find_nearest_type([AD, OD, T], stone, _, Object, Distance), 
    get_dict(x, Object, X), get_dict(y, Object, Y),
    navigate_to([AD, OD, T], X, Y, ActionListMove, Distance),
    (get_dict(inventory, AD, Inv), get_dict(stone_pickaxe, Inv, _) ->
    my_write(2, ActionListClick, left_click_c);
    my_write(4, ActionListClick, left_click_c)),
    append(ActionListMove, ActionListClick, ActionList).
% 10 points
% Predicate first calls the find_nearest_type predicate and gets the food to be gathered. Then asks navigate_to predicate to create
% necessary Action List. Only one left_click is enough to collect the food. Necessary
% click action are added with append to finalize Action List.
gather_nearest_food([AD, OD, T], ActionList) :-
    find_nearest_type([AD, OD, T], food, _, Object, Distance), 
    get_dict(x, Object, X), get_dict(y, Object, Y),
    navigate_to([AD, OD, T], X, Y, ActionListMove, Distance),
    append(ActionListMove, [left_click_c], ActionList).
% 10 points
% Predicate first calls the find_nearest_type predicate and gets the cobblestone to be mined. Then asks navigate_to predicate to create
% necessary Action List. If agent has stone_pickaxe in its inventory, then 2 left_clicks are needed. Otherwise 4 left_clicks are needed. Necessary
% click actions are added with append to finalize Action List.
mine_nearest_cobblestone([AD, OD, T], ActionList) :-
    find_nearest_type([AD, OD, T], cobblestone, _, Object, Distance), 
    get_dict(x, Object, X), get_dict(y, Object, Y),
    navigate_to([AD, OD, T], X, Y, ActionListMove, Distance),
    (get_dict(inventory, AD, Inv), get_dict(stone_pickaxe, Inv, _) ->
    my_write(2, ActionListClick, left_click_c);
    my_write(4, ActionListClick, left_click_c)),
    append(ActionListMove, ActionListClick, ActionList).
% Predicate to find a required RawType(stone|cobblestone|tree) for a given <ItemType>. It uses item_info and yields predicates from "constants.pro". If agent already have
% some log|cobblestone then these amount are substracted from required amount. 
required(ItemType, RawType, Amount, AD) :- 
    item_info(ItemType, ReqDict, _), get_dict(Ytype, ReqDict, ReqAmount), yields(RawType, Ytype, Yamount),
    ((get_dict(inventory, AD, Inv), get_dict(Ytype, Inv, AlreadyHave)) -> 
    ReqAmountF is (ReqAmount - AlreadyHave), ReqAmountF > 0;
    ReqAmountF is ReqAmount),
    ((0 is ReqAmountF mod Yamount) -> Amount is div(ReqAmountF, Yamount);
    Amount is (div(ReqAmountF, Yamount) + 1)).
% This predicate calls itself recursively to cover the cases when a type can not be directly obtained
% with chopping a tree or mining a cobblestone|stone.
required(ItemType, RawType, Amount, AD) :- 
    item_info(ItemType, ReqDict, _), get_dict(Itype, ReqDict, ReqAmount), required(Itype, RawType, Amount1, AD),
    ((get_dict(inventory, AD, Inv), get_dict(Itype, Inv, AlreadyHave)) -> 
    ReqAmountF is (ReqAmount - AlreadyHave), ReqAmountF > 0;
    ReqAmountF is ReqAmount),
    item_info(Itype, _, Yields),
    ((0 is ReqAmountF mod Yields) -> ReqAmountFF is div(ReqAmountF, Yields);
    ReqAmountFF is (div(ReqAmountF, Yields) + 1)),
    ((0 is ReqAmountFF mod Amount1) -> Amount is div(ReqAmountFF, Amount1);
    Amount is (div(ReqAmountFF, Amount1) + 1)).
% Predicate to finalize <ReqList> for a given ItemType with key-value pairs. (e.g. [stone-3, tree-2, ...]) It uses
% findall and calls required predicate to find all necessary amounts of stone|cobblestone|tree. Since <ReqList1> can contain more
% than one tree key, the amount of trees are summed and added as one key-value pair. Also since we can achive same goal with cobblestone|stone (since both yields cobblestone),
% the stone pair is deleted from the list.
find_req(ItemType, ReqList, AD) :-
    %get_dict(inventory, AD, Inv), put_dict([cobblestone=10], Inv, InvO), del_dict(inventory, AD, X, AD1),
    %put_dict(inventory, AD1, InvO, AD2), write(AD2),
    findall(RawType-Amount, required(ItemType, RawType, Amount, AD), ReqList1),
    findall(N, member(tree-N, ReqList1), ToSum),
    sum_list(ToSum, Sum),
    delete(ReqList1, tree-_, List1), delete(List1, stone-_, List2),
    append(List2, [tree-Sum], ReqList).
% Predicate that is used to give necessary Action List for collecting a tree, <NumTree> times. It uses chop_nearest_tree predicate <NumTree> times and appends all necassary Action Lists
% that chop_nearest_tree gives. execute_actions predicate also used for obtaining next state after chop_nearest_tree predicate's Action List is executed.
collect_tree(0, [], X, X) :- !.
collect_tree(NumTree, ActionList, [AD, OD, T], [ADF, ODF, TF]) :-
    chop_nearest_tree([AD, OD, T], ActionList1), execute_actions([AD, OD, T], ActionList1, [AD1, OD1, T1]),
    NumTree1 is NumTree - 1, collect_tree(NumTree1, ActionList2, [AD1, OD1, T1], [ADF, ODF, TF]),
    append(ActionList1, ActionList2, ActionList).
% Predicate that is used to give necessary Action List for collecting cobblestone, <NumTree> times. It uses mine_nearest_stone|mine_nearest_cobblestone predicate necessary times and appends all necessary Action Lists
% that mine_nearest_stone | mine_nearest_cobblestone gives. execute_actions predicate also used for obtaining next state after mine_nearest_stone | mine_nearest_cobblestone predicate's Action List is executed. The predicate
% first try to mine a stone, and if it is true, <NumTree> is decremented by 3. If there is no stone in the map (i. e. mine_nearest_stone fails), then it tries mine_nearest_cobblestone and if it is true, <NumTree> is
% decremented by 1.
collect_stone_cobblestone(NumSC, [], X, X) :-
    NumSC =< 0, !.
collect_stone_cobblestone(NumCS, ActionList, [AD, OD, T], [ADF, ODF, TF]) :-
    (mine_nearest_stone([AD, OD, T], ActionList1) ->
        execute_actions([AD, OD, T], ActionList1, [AD1, OD1, T1]),
        yields(stone, cobblestone, SC), NumCS1 is NumCS - SC,  collect_stone_cobblestone(NumCS1, ActionList2, [AD1, OD1, T1], [ADF, ODF, TF]),
        append(ActionList1, ActionList2, ActionList);
        mine_nearest_cobblestone([AD, OD, T], ActionList1), execute_actions([AD, OD, T], ActionList1, [AD1, OD1, T1]),
        NumCS1 is NumCS - 1, collect_stone_cobblestone(NumCS1, ActionList2, [AD1, OD1, T1], [ADF, ODF, TF]), append(ActionList1, ActionList2, ActionList)
    ).
% Predicate that gives the all necessary Action List elements for a given <ItemType>. It uses find_req predicate for the ones whose requirements are defined on "constants.pro". Since castle is not defined in 
% that file and modifying that file is not possible, it is manuelly added if find_req fails. After finding necessary <ReqList>, this predicate calls collect_stone_cobblestone | collect_tree if necessary. Then all
% necessary actions are added to Action List. If <ItemType> requires an item that needs to be crafted, necessary craft actions are also added to Action List.
collect_requirements([AD, OD, T], ItemType, ActionList) :-
    ((not(ItemType = castle), find_req(ItemType, ReqList, AD)) ->
        ReqList = ReqList;
        ItemType = castle,
        ((get_dict(inventory, AD, INVObject), get_dict(cobblestone, INVObject, AlreadyHCS)) ->
        RealReq is 9 - AlreadyHCS, ReqList = [cobblestone-RealReq];
        ReqList = [cobblestone-9])),
    (member(cobblestone-X, ReqList) -> collect_stone_cobblestone(X, ActionList1, [AD, OD, T], [ADF, ODF, TF]);
    ActionList1 = [], ADF = AD, ODF = OD, TF = T),
    (member(tree-Y, ReqList) -> collect_tree(Y, ActionList2, [ADF, ODF, TF], _);
    ActionList2 = []),
    append(ActionList1, ActionList2, ActionList3),
    ((item_info(ItemType, ReqDict, Yields), get_dict(stick, ReqDict, ReqAmount)) ->
    ((0 is ReqAmount mod Yields) -> ReqAmountF is div(ReqAmount, Yields);
    ReqAmountF is (div(ReqAmount, Yields) + 1)),
    my_write(ReqAmountF, ActionList4, craft_stick);
    ActionList4 = []),
    append(ActionList3, ActionList4, ActionList).
% 5 points
% Predicate to find a suitable castle locations (i. e. 3*3 empty area). It first uses findall to find all occupied locations and try combination of coordinates for an suitable area, until
% intersection between <CastleLİst> and <OccupiedList> is an empty list.
find_castle_location([_, OD, _], XMin, YMin, XMax, YMax) :- 
findall(X-Y, (get_dict(_, OD, Object), get_dict(x, Object, X), get_dict(y, Object, Y)), OccupiedList),
read_file(_,[YLimit, XLimit]), findall(XNum, between(1, XLimit, XNum), XList), findall(YNum, between(1, YLimit, YNum), YList),
member(XMin, XList), member(YMin, YList), X2 is XMin + 1, XMax is X2 + 1,
Y2 is YMin + 1, YMax is Y2 + 1, XMax =< XLimit, YMax =< YLimit,
findall(A-B, (member(A, [XMin, X2, XMax]), member(B, [YMin, Y2, YMax])), CastleList),
intersection(OccupiedList, CastleList, []).
% 15 points
% Predicate to make a castle. It first uses collect_requirements predicate to find necessary actions for obtaining castle's requirements. Then execute_actions is called to obtain the next state
% after executing these actions. Then find_castle_location is called to find whether map has a suitable location to build a castle. If true, than Manhattan Distance betwwen agent's location and
% castle location's center, then navigate_to is called to get necessary actions for agent to go there. All these actions are added to Action List. Lastly, place actions are added to Action List to finalize the
% actions that are required to make a castle.
make_castle([AD, OD, T], ActionList) :-
    collect_requirements([AD, OD, T], castle, ActionList1), execute_actions([AD, OD, T], ActionList1, [AD1, OD1, T1]),
    find_castle_location([AD1, OD1, T1], XMin, YMin, XMax, YMax), !, get_dict(x, AD1, XLoc), get_dict(y, AD1, YLoc),
    XSum is XMin + XMax, XCenter is div(XSum, 2), YSum is YMin + YMax, YCenter is div(YSum, 2),
    manhattan_distance([XCenter, YCenter], [XLoc, YLoc], Distance), navigate_to([AD1, OD1, T1], XCenter, YCenter, ActionList2, Distance),
    append(ActionList1, ActionList2, ActionList3),
    PlaceList = [place_c, place_e, place_n, place_ne, place_nw, place_s, place_se, place_sw, place_w],
    append(ActionList3, PlaceList, ActionList).
