describe('Rotas POST Endereço', () => {

    beforeEach(() => {
        cy.request({
            method: 'POST', url: '/cliente', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        });
    });

    afterEach(() => {
        cy.request({
            method: 'DELETE',
            url: '/cliente/1',
            failOnStatusCode: false
        });
    });

    it('Criar Endereço - Sucesso', () => {
        cy.request({
            method: 'POST',
            url: '/cliente/1/endereco',
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
            expect(Response.body[1].contato).to.equal("55229785634");
            expect(Response.body[1].nome).to.equal('Priscila G. Vieira');
        });
    });

});