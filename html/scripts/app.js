
var bankAmount = "0";
var money = "0"
var time = "0"
var converttime = "0"
var wpispin = "0"



window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type == "clear") {
        $(".historia").remove();
    }

   
    if (data.type === 'updateUI') {

        bankAmount = data.bankMoney
        money = data.money
        const moneyBankElements = document.querySelectorAll('.money-bank');
        moneyBankElements.forEach(element => {
            element.textContent = `${data.bankMoney}$`;
        });

        const moneyeq = document.querySelectorAll('.money-eq');
        moneyeq.forEach(element => {
            element.textContent = `${data.money}$`;
        });
    }

    if (data.type === 'historia') {
        let timestamp = data.time;
        let formattedDate = new Date(timestamp).toLocaleString('pl-PL', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
        var historiaElements = $( ".historia" );

        if (!historiaElements.filter(`[data-timestamp="${timestamp}"]`).length) {
            var boxHistoria = `
                <div class="historia" data-timestamp="${timestamp}">
                    <p>${data.typ}</p>
                    <p style="color: ${getColor(data.typ)}">${data.kwota}</p>
                    <p>${formattedDate}</p>
                </div>
            `;

            $("#transactionContainer").prepend(boxHistoria);

            if (historiaElements.length > 10) {
                historiaElements.last().remove();
            }
        }

        function getColor(typ) {
            switch (typ) {
                case 'WYPLATA':
                case 'PRZELEW_W':
                    return 'red';
                case 'WPLATA':
                case 'PRZELEW_P':
                    return 'green';
                default:
                    return 'white'; 
            }
        }
    }
});







window.addEventListener('message', (event) => {
    const data = event.data;

 
    if (data.type === 'open') {
        const showpin = data.showPin;

        const showmenu = data.showMenu;

        const corectpin = data.pinaccept;

        if (showmenu) {
            document.getElementById('loader').style.display = 'flex';
        } else {
            document.getElementById('loader').style.display = 'none';
        }
        
        if (showpin) {
            document.getElementById('pincode').style.display = 'block';
        } else {
            document.getElementById('pincode').style.display = 'none';
        }
        if (corectpin) {
            document.getElementById('pincode').style.display = 'none';
            document.getElementById('atm').style.display = 'block';
        } else {
            document.getElementById('atm').style.display = 'none';
        }
    }
});

function sprpin() {   
    $.post(`https://esx_banking/sprpin`, JSON.stringify({ wpispin: wpispin}));
    clearInputs()
}


function wyplac() {

    var kwotaDoWyplaty = document.getElementById("input-wyplac").value;

   
    $.post(`https://esx_banking/wyplac`, JSON.stringify({ bankmoney: kwotaDoWyplaty, bankaconmoney: bankAmount}));
    clearInputs()
}
function wyplacatm() {

    var kwotaDoWyplaty = document.getElementById("input-wyplac2").value;

   
    $.post(`https://esx_banking/wyplacatm`, JSON.stringify({ bankmoney: kwotaDoWyplaty, bankaconmoney: bankAmount}));
    clearInputs()
}
function wplac() {

    var kwotaDoWyplaty = document.getElementById("input-wplac").value;

    $.post(`https://esx_banking/wplac`, JSON.stringify({ bankmoney: kwotaDoWyplaty, bankaconmoney: bankAmount}));
    clearInputs()
}
function transfer() {

    var id = document.getElementById("transfer-id").value;
    var transferkwota = document.getElementById("transfer-kwota").value;

    $.post(`https://esx_banking/transfer`, JSON.stringify({ idtarget: id, kwotatransfer: transferkwota}));
    clearInputs()
}


function pin() {
    
    var pin = document.getElementById("input-uppin").value;    
    $.post(`https://esx_banking/uppin`, JSON.stringify({pin: pin}));
    clearInputs()
}

document.onkeyup = function (data) {
    if (data.which == 27) {
        $.post('https://esx_banking/exit', JSON.stringify({}));
        clearInputs()
        
    }
}
function exit() {
    $.post('https://esx_banking/exit', JSON.stringify({}));
    clearInputs()
}
function clearInputs() {
    var inputs = document.querySelectorAll('input');
    inputs.forEach(function(input) {
        input.value = '';
    });
}