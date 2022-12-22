describe('Rotas Post de Cliente', () => {

    it('Criar cliente - Sucesso', () => {
        cy.request({
            method: 'POST', url: '/cliente', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].Message).to.equal('Cliente salvo com sucesso!');
            expect(Response.body[1].id).to.equal(1);
            expect(Response.body[1].nome).to.equal('Priscila G. Vieira');
        });
    });

    it('Criar cliente - Falha', () => {
        cy.request({
            method: 'POST', url: '/cliente', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(400);
            expect(Response.body.ERROR).to.equal('Cliente possui cadastro');
        });
    });

});

describe('Rotas GET de Cliente', () => {

    it('Buscar todos os clientes', () => {
        cy.request('/cliente').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].id).to.equal(1);
            expect(Response.body[0].nome).to.equal('Priscila G. Vieira');
        });
    });

    it('Buscar clientes por ID', () => {
        cy.request('/cliente/1').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(1);
        });
    });

    it('Buscar clientes por Nº contato', () => {
        cy.request('/cliente/55229785634').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.contato).to.equal('55229785634');
        });
    });
});