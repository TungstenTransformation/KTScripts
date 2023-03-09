# How to read locator settings.
Every project setting is available in the scripting environment through the global variable **project**.  
You can seriously destroy a project by making changes to the **project** object. Make any changes here at your own risk. Don't expect sympathetic support from Tech Support if you ruin your project this way :-).

# Reading Locator Settings.
Lets' say you want access to the **Mininum confidence** of the Database Locator.  
![image](https://user-images.githubusercontent.com/103566874/224000038-667ccc01-9d85-4b82-bcdf-f8268e1df51f.png)
1. Open the script window and press **Play**.
1. Put **project.** into the Watch window.  
![image](https://user-images.githubusercontent.com/103566874/224000707-64b41a0d-c4e5-429e-8557-5c4594d0872f.png)
1. You want to look at locator **DB** in class **Document**. Drill down into the locator definition  **project.classbyName("Document").Locators.ItemByName("DB").LocatorMethod**  
![image](https://user-images.githubusercontent.com/103566874/224001114-96bf8005-b3ce-4c91-a78a-0f5e3603e09a.png)
1. This shows  that the Database Locator is of Type **CSCDatabaseLocator** (ignore the **I** for interface). This will give us access to all settings in the locator.
1. Open Menu **Edit/References..** in the Script Editor.
1. Find the Database Locator under **Kofax Cascade**, select it and press OK.  
![image](https://user-images.githubusercontent.com/103566874/224001928-7e77850b-5fb4-4160-ab46-fcafceaad4d4.png)

2. Add the following script wherever you need it.
    ```vb
    Dim DBLocDef As CscDatabaseLocator
    Set DBLocDef = Project.ClassByName("Document").Locators.ItemByName("DB").LocatorMethod
    DBLocDef.
    ```
2. You can now see the attributes of the locator and use them in your script.  
*You can change locators, but you risk destroying your project. Be warned!!*
![image](https://user-images.githubusercontent.com/103566874/224002612-bc9f11a4-0327-49e6-aa6c-7e3f3763be07.png)

