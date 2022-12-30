describe('Rotas POST Endereço', () => {

    beforeEach(() => {
        cy.request({
            method: 'POST', url: '/cliente', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        });
    });

    it('Criar Endereço - Sucesso', () => {
        cy.request({
            method: 'POST',
            url: '/cliente/55229785634/endereco',
            body: {
                "ID": 0,
                "CLIENTE": 4,
                "RUA": "Av. Country Clube dos Engenheiros",
                "NUMERO": "2042",
                "BAIRRO": "Clube dos Engenheiros",
                "COMPLEMENTO": "Casa 120",
                "CIDADE": "Araruama",
                "ESTADO": "RJ"
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].Message).to.equal('Endereço adicionado com sucesso!');
            expect(Response.body[1].CLIENTE.CONTATO).to.equal("55229785634");
            expect(Response.body[1].CLIENTE.NOME).to.equal('Priscila G. Vieira');
        });
    });

    afterEach(() => {
        cy.request({
            method: 'DELETE',
            url: '/cliente/55229785634',
            failOnStatusCode: false
        });
    });

});

describe('Rotas GET Endereço', () => {
    beforeEach(() => {
        cy.request({
            method: 'POST', url: '/cliente', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        });

        cy.request({
            method: 'POST',
            url: '/cliente/55229785634/endereco',
            body: {
                "ID": 0,
                "RUA": "Av. Country Clube dos Engenheiros",
                "NUMERO": "2042",
                "BAIRRO": "Clube dos Engenheiros",
                "COMPLEMENTO": "Casa 120",
                "CIDADE": "Araruama",
                "ESTADO": "RJ"
            }
        });

        cy.request({
            method: 'POST',
            url: '/cliente/55229785634/endereco',
            body: {
                "ID": 0,
                "RUA": "Rua Érica Reis",
                "NUMERO": "35",
                "BAIRRO": "Outeiro",
                "COMPLEMENTO": "Casa 4",
                "CIDADE": "Belford Roxo",
                "ESTADO": "RJ"
            }
        })
    });

    it('Buscar endereços de cliente', () => {
        cy.request('/cliente/55229785634/endereco').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.contato).to.equal('55229785634');
            expect(Response.body.ENDERECOS[0].rua).to.equal('Av. Country Clube dos Engenheiros');
            expect(Response.body.ENDERECOS[1].rua).to.equal('Rua Érica Reis');
        });
    });

    afterEach(() => {
        cy.request({
            method: 'DELETE',
            url: '/cliente/55229785634',
            failOnStatusCode: false
        });
    });
});