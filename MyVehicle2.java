import Vehicle;

class MyVehicle2 {

   private static void checkIt (Vehicle wheels) {
   
      if ( wheels.isRegistered() )
         System.out.println (wheels);
      else
         System.out.println ("Unregistered");
	}

   public static void main (String[] args) {
      Vehicle mywagon = new Vehicle();
      Vehicle hiswagon = new Vehicle();
      Vehicle yourwagon = mywagon; //now changes to mywagon affect yourwagon.
                                   // and vice versa, as shown below.

      private static void checkAll {
	      checkIt (mywagon);
	      checkIt (yourwagon);
	      checkIt (hiswagon);
		}
	            
      mywagon.owner = "Steven";
      mywagon.idNumber = 123456;
      
	   // Do I need an inner class here?
      
      checkAll;
      
      yourwagon.owner = "Veva";

      checkAll;

      hiswagon.Register (778899, "Eli");
      hiswagon.Register (778899, "Joe");

      checkAll;
   }
}