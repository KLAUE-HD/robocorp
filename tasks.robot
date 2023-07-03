*** Settings ***
Library     RPA.Browser.Selenium
Library     RPA.HTTP
Library     RPA.PDF
Library     RPA.Tables
Library     RPA.Robocorp.WorkItems
Library     RPA.Desktop
Library     RPA.Word.Application
Library     RPA.MSGraph
Library     Collections
Library     OperatingSystem
Library     Screenshot
Library     RPA.Archive


*** Variables ***
${counter}      1


*** Tasks ***
Create your own robot
    Open the Website
    Close the annoying modal
    Download the CSV File
    ${orders} =    Read table from CSV    orders.csv
    Fill in all Orders    ${orders}
    Create a ZIP file of the receipts


*** Keywords ***
Open the Website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the CSV File
    Download    https://robotsparebinindustries.com/orders.csv

Close the annoying modal
    Click Button    OK

Fill the form
    [Arguments]    ${row}
    Wait Until Element Is Visible    xpath://select[@id='head']
    Select From List By Value    xpath://select[@id='head']    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath://input[@class='form-control'and @type='number']    ${row}[Legs]
    Input Text    xpath://input[@class='form-control'and @type='text']    ${row}[Address]

    Click Button    preview
    Submit the order
    ${pdf} =    Store the receipt as a PDF file    ${row}[Order number]
    ${screenshot} =    Take a screenshot of the robot    ${row}[Order number]

    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}

    Click Button    order-another
    Close the annoying modal

Submit the order
    Click Button    id:order
    FOR    ${i}    IN RANGE    9999999
        ${success} =    Is Element Visible    id:receipt
        IF    ${success}    BREAK
        Click Button    id:order
    END

Fill in all Orders
    [Arguments]    ${orders}
    FOR    ${row}    IN    @{orders}
        Fill the form    ${row}
        Sleep    2s
    END

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:order-completion
    ${order_number} =    Get Text    xpath://div[@id="receipt"]/p[1]
    # Log    ${order_number}
    ${receipt_html} =    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${receipt_html}    ${CURDIR}${/}output${/}receipts${/}${order_number}.pdf
    RETURN    ${CURDIR}${/}output${/}receipts${/}${order_number}.pdf

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Screenshot    id:robot-preview    ${CURDIR}${/}output${/}${order_number}.png
    RETURN    ${CURDIR}${/}output${/}${order_number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Close Pdf    ${pdf}

Create a ZIP file of the receipts
    Archive Folder With Zip    ${CURDIR}${/}output${/}receipts    ${CURDIR}${/}output${/}receipt.zip
