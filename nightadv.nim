import adventure, rdstdin

gameworld:
   directions = [North = "Βόρεια", South = "Νότια",
      East = "Ανατολικά", West = "Δυτικά"]
   room Garden:
      message = "Βρίσκεσαι στον κήπο. Παντού σκοτάδι."
      moves = {South: Hall}
   room Bathroom:
      message = "Βρίσκεσαι στο μπάνιο. Ακούς θόρυβο."
      moves = {East: Hall}
   room Hall:
      message = "Βρίσκεσαι στο χωλ. Παραλίγο να σκοντάψεις. Σκάλα ανατολικά"
      moves = {North: Garden, South: LivingRoom, East: Storeroom, West: Bathroom}
   room Storeroom:
      message = "Βρίσκεσαι στην αποθήκη. Η ατμόσφαιρα είναι αποπνικτική. Σκάλα Δυτικά, Μονοπάτι Νότια."
      moves = {South: Kitchen, West: Hall}
   room SittingRoom:
      message = "Έφτασες στο καθιστικό. Βρήκες τον πατέρα σου."
      moves = {South: DinningRoom, East: LivingRoom}
      lossroom = true
   room LivingRoom:
      message = "Βρίσκεσαι στο σαλόνι. Ακούγεται μουσική."
      moves = {North: Hall, South: Kitchen, West: SittingRoom}
   room DinningRoom:
      message = "Βρίσκεσαι στην τραπεζαρία. Τα πάντα είναι ανάστατα."
      moves = {North: SittingRoom, South: Hallway}
   room Hallway:
      message = "Βρίσκεσαι στο διάδρομο. Είναι σκοτεινά. Σκάλα Νότια"
      moves = {North: DinningRoom, South: UpperHallway, East: Kitchen}
   room Kitchen:
      message = "Είσαι στη κουζίνα. Ακούς φωνές."
      moves = {North: LivingRoom, West: Hallway}
   room UpperHallway:
      message = "Είσαι στον πάνω διάδρομο. Παντού ησυχία. Σκάλα Βόρεια."
      moves = {North: Hallway, South: ParentsBedroom, East: YourBedroom, West: BrothersBedroom}
   room BrothersBedroom:
      message = "Είσαι στο δωμάτιο του αδερφού σου. Ο αδερφός σου σε μαρτυρά!"
      moves = {East: UpperHallway}
      lossroom = true
   room ParentsBedroom:
      message = "Είσαι στο δωμάτιο των γονέων σου. Η μητέρα σου σε έπιασε."
      moves = {North: UpperHallway}
      lossroom = true
   room YourBedroom:
      message = "Είσαι στο δωμάτιο σου. Είσαι ασφαλής."
      moves = {West: UpperHallway}
      winroom = true

proc getInput(room: Room): Direction =
   echo "Έξοδοι: ", room.printMoves()
   while not room.hasMove(result):
      let choice = readLineFromStdin("Πού θες να πας; ")
      case choice
      of "Βόρεια":
         result = North
      of "Νότια":
         result = South
      of "Ανατολικά":
         result = East
      of "Δυτικά":
         result = West
      else:
         discard

proc nightadv =
   var room = Garden
   var endgame = false
   while not endgame:
      echo room.message
      if room.isWinroom():
         echo "Κέρδισες! Η περιπέτεια τελείωσε."
         endgame = true
      elif room.isLossroom():
         echo "Έχασες! Η περιπέτεια τελείωσε."
         endgame = true
      else:
         let direction = getInput(room)
         room = room.move(direction)

nightadv()
