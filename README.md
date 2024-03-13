A simple addon that browses your bags and saved auction data, it it gives the optimal way to spend your materials to make most money.

Steps:

- Get alchemy materials in inventory (TODO: add bank) - Requires BagBrother(Bagnon)
- Get alchemy recipes you can craft with the available materials
- Get auction house prices for all the materials and all the recipes you can create - Requires AuctionDB
- Put all the previous data into a simplex tableau
- Solve the simplex tableau and return optional steps to make most profit

<!-- Build:
I want to be able to run the whole thing as plain lua script with mock data as the technicalities behind are most complex and I didn't want to debug everything in wow.
The process has to be like this:
  For addon release I need to amalg and to not import testing things, cant rely on running the script and caching all requires because data available only in client.
  I need to build it clean and then add the addon core.

  For testing I can either amalg or I don't have to.  -->
