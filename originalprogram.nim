import rdstdin

type
   Room {.pure.} = enum
      None, Garden, Bathroom, Hall, Storeroom, SittingRoom, LivingRoom,
      DinningRoom, Hallway, Kitchen, UpperHallway, BrothersBedroom,
      ParentsBedroom, Bedroom

   Direction {.pure.} = enum
      Unknown,
      North = "βόρεια",
      South = "νότια",
      East = "ανατολικά",
      West = "δυτικά"

   ValidRooms = range[low(Room).succ..high(Room)]
   ValidDir = range[low(Direction).succ..high(Direction)]

const
   rooms: array[ValidRooms, string] = [
      Garden: "Βρίσκεσαι στον κήπο. Παντού σκοτάδι.",
      Bathroom: "Βρίσκεσαι στο μπάνιο. Ακούς θόρυβο.",
      Hall: "Βρίσκεσαι στο χωλ. Παραλίγο να σκοντάψεις. Σκάλα ανατολικά",
      Storeroom: "Βρίσκεσαι στην αποθήκη. Η ατμόσφαιρα είναι αποπνικτική. Σκάλα Δυτικά, Μονοπάτι Νότια.",
      SittingRoom: "Έφτασες στο καθιστικό. Βρήκες τον πατέρα σου.",
      LivingRoom: "Βρίσκεσαι στο σαλόνι. Ακούγεται μουσική.",
      DinningRoom: "Βρίσκεσαι στην τραπεζαρία. Τα πάντα είναι ανάστατα.",
      Hallway: "Βρίσκεσαι στο διάδρομο. Είναι σκοτεινά. Σκάλα Νότια",
      Kitchen: "Είσαι στη κουζίνα. Ακούς φωνές.",
      UpperHallway: "Είσαι στον πάνω διάδρομο. Παντού ησυχία. Σκάλα Βόρεια.",
      BrothersBedroom: "Είσαι στο δωμάτιο του αδερφού σου. Ο αδερφός σου σε μαρτυρά!",
      ParentsBedroom: "Είσαι στο δωμάτιο των γονέων σου. Η μητέρα σου σε έπιασε.",
      Bedroom: "Είσαι στο δωμάτιο σου. Είσαι ασφαλής."]

   moves: array[ValidRooms, array[ValidDir, Room]] = [
      Garden: [None, Hall, None, None],
      Bathroom: [None, None, Hall, None],
      Hall: [Garden, Livingroom, Storeroom, Bathroom],
      Storeroom: [None, Kitchen, None, Hall],
      SittingRoom: [None, DinningRoom, Livingroom, None],
      LivingRoom: [Hall, Kitchen, None, Sittingroom],
      DinningRoom: [Sittingroom, Hallway, None, None],
      Hallway: [DinningRoom, UpperHallway, Kitchen, None],
      Kitchen: [Livingroom, None, None, Hallway],
      UpperHallway: [Hallway, ParentsBedroom, Bedroom, BrothersBedroom],
      BrothersBedroom: [None, None, UpperHallway, None],
      ParentsBedroom: [UpperHallway, None, None, None],
      Bedroom: [None, None, None, UpperHallway]]

   winrooms = {Bedroom}
   lossrooms = {SittingRoom, BrothersBedroom, ParentsBedroom}

proc getInput(room: Room): Direction =
   var possibleMoves: set[Direction]
   for direction, destination in moves[room]:
      if destination != None:
         possibleMoves.incl direction
   echo "Έξοδοι: ", possibleMoves
   while result notin possibleMoves:
      let choice = readLineFromStdin("Πού θες να πας; ")
      case choice
      of "βόρεια":
         result = North
      of "νότια":
         result = South
      of "ανατολικά":
         result = East
      of "δυτικά":
         result = West
      else:
         discard

proc adventure =
   var room = Garden
   var endgame = false
   while not endgame:
      echo rooms[room]
      if room in winrooms:
         echo "Κέρδισες! Η περιπέτεια τελείωσε."
         endgame = true
      elif room in lossrooms:
         echo "Έχασες! Η περιπέτεια τελείωσε."
         endgame = true
      else:
         let direction = getInput(room)
         room = moves[room][direction]

adventure()
