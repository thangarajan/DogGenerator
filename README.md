# DogGenerator
The requirement is random dog generator
I have followed the MVVM design Pattern 
Created the DGHomeViewController, DGDogGeneratedViewController, DGRecentDogsViewController views
Created the DGGenerateViewModel, DGRecentViewModel view Models
Created the DGDogModel as a Model
Saving Image and Datas
LRU logic was impllemented in CacheLRU class 

DGGenerateViewModel

Handled the Image downloading and I am saving UIImage into localfile path and the data key and filepath name was saving into LRUCache file
And the I have used the Data.Plist file for saving the key and localfilepath as value

So, when app was killed i am reading the data from the plist using allkeys with value and updating the LRUCache file
