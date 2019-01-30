import macros

proc createMovesArray(moves, directions, none: NimNode): NimNode =
   # Create an array of Room destinations from a Room.
   result = newTree(nnkBracket)
   for d in directions:
      expectKind(d, nnkIdent)
      var room = none
      for m in moves:
         expectKind(m, nnkExprColonExpr)
         # Direction: Room
         if d.eqIdent(m[0]):
            room = m[1]
            break
      result.add(room)

proc createMovesSet(moves: NimNode): NimNode =
   # Create a set of every possible move in a Room.
   result = newTree(nnkCurly)
   for m in moves:
      expectKind(m, nnkExprColonExpr)
      result.add(m[0])

template newConstArray(name, idxTy, baseTy) =
   const name: array[idxTy, baseTy] = []
template newConstSet(name, baseTy, value) =
   const name: set[baseTy] = value
template makeEnum(name, none) =
   type name {.pure.} = enum
      none
template makeRange(e) =
   range[low(e).succ..high(e)]
template createMethods(roomTy, dirTy, msgVar, destVar, movesVar, winVar, lossVar) =
   proc move(r: roomTy; d: dirTy): roomTy = destVar[r][d]
   proc message(r: roomTy): string = msgVar[r]
   proc hasMove(r: roomTy; d: dirTy): bool = d in movesVar[r]
   proc isWinroom(r: roomTy): bool = r in winVar
   proc isLossroom(r: roomTy): bool = r in lossVar
   proc printMoves(r: roomTy): string = $movesVar[r]

macro gameworld*(body: untyped): untyped =
   expectKind(body, nnkStmtList)
   expectMinLen(body, 2)
   let dir = body[0]
   expectKind(dir, nnkAsgn)
   assert eqIdent(dir[0], "directions"), dir.lineInfo & ": Define possible directions first"
   expectKind(dir[1], nnkBracket)
   let directions = newTree(nnkBracket)
   var dirs: seq[NimNode]
   for d in dir[1]:
      if d.kind == nnkExprEqExpr:
         dirs.add newTree(nnkEnumFieldDef).add(d[0], d[1])
         directions.add d[0]
      else:
         dirs.add d
         directions.add d
   var rooms: seq[NimNode]
   var moves: seq[NimNode]
   let messages = newTree(nnkBracket)
   let winrooms = newTree(nnkCurly)
   let lossrooms = newTree(nnkCurly)
   for i in 1 ..< body.len:
      let room = body[i]
      expectKind(room, nnkCommand)
      assert eqIdent(room[0], "room"), room.lineInfo & ": Invalid command"
      let name = room[1]
      rooms.add name
      let params = room[2]
      expectKind(params, nnkStmtList)
      for i in 0 ..< params.len:
         let rec = params[i]
         expectKind(rec, nnkAsgn)
         let x = rec[0]
         if eqIdent(x, "message"):
            messages.add(rec[1])
         elif eqIdent(x, "moves"):
            moves.add(rec[1])
         elif eqIdent(x, "winroom"):
            if eqIdent(rec[1], "true"):
               winrooms.add(name)
         elif eqIdent(x, "lossroom"):
            if eqIdent(rec[1], "true"):
               lossrooms.add(name)
         else:
            error(rec.lineInfo & ": Invalid field")
   # Prevent typing errors
   let roomTy = ident("Room")
   let dirTy = ident("Direction")
   # Create unique symbols for the variable names
   let msgVar = genSym(nskConst, "messages")
   let destVar = genSym(nskConst, "destinations")
   let movesVar = genSym(nskConst, "moves")
   let winVar = genSym(nskConst, "winrooms")
   let lossVar = genSym(nskConst, "lossrooms")
   # Create unique symbols for none fields
   let dirNone = genSym(nskEnumField, "None")
   let roomNone = genSym(nskEnumField, "None")
   # Make the Room and Direction enums
   let dirEnum = getAst(makeEnum(dirTy, dirNone))
   dirEnum[0][2].add dirs
   let roomEnum = getAst(makeEnum(roomTy, roomNone))
   roomEnum[0][2].add rooms
   # Create range types that start after the error field
   let roomRange = getAst(makeRange(roomTy))
   let dirRange = getAst(makeRange(dirTy))
   # Make the messages array
   let msgArray = getAst(newConstArray(msgVar, roomRange, ident("string")))
   msgArray[0][2] = messages
   # Declare the inner types of the destinations and moves arrays.
   let movesDArrayTy = newNimNode(nnkBracketExpr).add(ident("array"), dirRange, roomTy)
   let movesSetArrayTy = newNimNode(nnkBracketExpr).add(ident("set"), dirTy)
   # Make arrays holding destinations, moves for every Room.
   let movesDArray = getAst(newConstArray(destVar, roomRange, movesDArrayTy))
   let movesSetArray = getAst(newConstArray(movesVar, roomRange, movesSetArrayTy))
   # For every Room create room destinations array and possible moves set
   for m in moves:
      let movesArray = createMovesArray(m, directions, roomNone)
      let movesSet = createMovesSet(m)
      movesDArray[0][2].add(movesArray)
      movesSetArray[0][2].add(movesSet)
   # Make winrooms, lossrooms sets.
   let winSet = getAst(newConstSet(winVar, roomTy, winrooms))
   let lossSet = getAst(newConstSet(lossVar, roomTy, lossrooms))
   # Create the pseudo methods needed to access the hidden variables
   let methods = getAst(createMethods(roomTy, dirTy,
      msgVar, destVar, movesVar, winVar, lossVar))
   # Add everything to result.
   result = newStmtList(dirEnum, roomEnum, msgArray, movesDArray,
      movesSetArray, winSet, lossSet, methods)
   echo result.repr
